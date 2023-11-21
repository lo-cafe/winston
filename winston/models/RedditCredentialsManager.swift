//
//  AccountsManager.swift
//  winston
//
//  Created by Igor Marcossi on 19/11/23.
//

import Foundation
import KeychainAccess
import Alamofire
import SwiftUI
import Defaults
import Combine

struct RedditCredential: Identifiable, Equatable, Hashable, Codable {
  static let secretTokenKeychainLabel = "secretToken"
  static let refreshTokenKeychainLabel = "refreshToken"
  static let apiAppSecretKeychainLabel = "apiAppSecret"
  var id: String { self.apiAppID }
  let apiAppID: String
//    didSet {
//      RedditCredentialsManager.keychain.allKeys().forEach { key in
//        if key == RedditCredential.secretTokenKeychainLabel || key == RedditCredential.refreshTokenKeychainLabel {
//          try? RedditCredentialsManager.keychain.remove(key)
//        }
//      }
//    }
//  }
  
  var apiAppSecret: String? { RedditCredentialsManager.keychain["\(self.apiAppID)\(RedditCredentialsManager.keychainEntryDivider)\(RedditCredential.apiAppSecretKeychainLabel)"] }
  
  var secretToken: SecretToken? = nil {
    didSet {
      if let secretToken = secretToken {
        let keychainKey = "\(self.apiAppID)\(RedditCredentialsManager.keychainEntryDivider)\(RedditCredential.secretTokenKeychainLabel)"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(secretToken) {
          RedditCredentialsManager.keychain[keychainKey] = String(decoding: encoded, as: UTF8.self)
        }
      }
    }
  }
  var refreshToken: String? = nil {
    didSet {
      if let refreshToken = refreshToken {
        let keychainKey = "\(self.apiAppID)\(RedditCredentialsManager.keychainEntryDivider)\(RedditCredential.refreshTokenKeychainLabel)"
        RedditCredentialsManager.keychain[keychainKey] = refreshToken
      }
    }
  }
  
  init(apiAppID: String, secretToken: SecretToken? = nil, refreshToken: String? = nil) {
    self.apiAppID = apiAppID
    self.secretToken = secretToken
    self.refreshToken = refreshToken
  }
  
  enum CodingKeys: String, CodingKey { case apiAppID, secretToken, refreshToken }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    apiAppID = try values.decode(String.self, forKey: .apiAppID)
    secretToken = try values.decodeIfPresent(SecretToken.self, forKey: .secretToken)
    refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(apiAppID, forKey: .apiAppID)
    try container.encodeIfPresent(secretToken, forKey: .secretToken)
    try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
  }
  
  
  func getUpToDateToken(forceRenew: Bool = false, count: Int = 0) async -> String? {
    if
      let refreshToken = self.refreshToken,
      let apiAppSecret = self.apiAppSecret,
      forceRenew ||
        Double(Date().timeIntervalSince1970 - ((self.secretToken?.lastRefresh ?? Date()).timeIntervalSince1970 - Double(self.secretToken?.expiration ?? 86400 * 10))) > Double(max(0, (self.secretToken?.expiration ?? 0) - 100))
    {
      let payload = RedditAPI.RefreshAccessTokenPayload(refresh_token: refreshToken)
      let response = await AF.request(
        "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
        method: .post,
        parameters: payload,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: RedditAPI.shared.fetchRequestHeaders(includeAuth: false))
        .authenticate(username: self.apiAppID, password: apiAppSecret)
        .serializingDecodable(RedditAPI.RefreshAccessTokenResponse.self).response
      switch response.result {
      case .success(let data):
        var selfCopy = self
        selfCopy.secretToken = .init(token: data.access_token, expiration: data.expires_in, lastRefresh: Date())
        if let myIndex = RedditCredentialsManager.shared.credentials.firstIndex(where: { $0.id == self.id }) {
          await MainActor.run { [selfCopy] in
            RedditCredentialsManager.shared.credentials[myIndex] = selfCopy
          }
        }
        return data.access_token
      case .failure(let error):
        if count < 3 {
          return await self.getUpToDateToken(forceRenew: forceRenew, count: count + 1)
        }
        print(error)
        return nil
      }
    }
    return nil
  }
  
  struct SecretToken: Equatable, Hashable, Codable, Defaults.Serializable {
    let token: String
    var expiration: Int? = nil
    var lastRefresh: Date? = nil
  }
}


class RedditCredentialsManager: ObservableObject {
  static let shared = RedditCredentialsManager()
  static let keychainEntryDivider = "\\--(*.*)--/"
  static let keychainService = "lo.cafe.winston.reddit-credentials"
  static let keychain = Keychain(service: RedditCredentialsManager.keychainService).synchronizable(Defaults[.syncKeyChainAndSettings])
  @Published var credentials: [RedditCredential]
  var cancelables: [Defaults.Observation] = []
  
  var selectedCredential: RedditCredential? {
    if credentials.count > 0 {
      return credentials.first { $0.id == Defaults[.redditCredentialSelectedID] } ?? credentials[0]
    }
    return nil
  }
  
  convenience init() {
    let kc = RedditCredentialsManager.keychain
    
    if let oldApiAppID = kc["apiAppID"], let oldApiAppSecret = kc["apiAppSecret"] {
      kc["\(oldApiAppID)\(Self.keychainEntryDivider)\(RedditCredential.apiAppSecretKeychainLabel)"] = oldApiAppSecret
      if let oldRefreshToken = kc["refreshToken"] {
        kc["\(oldApiAppID)\(Self.keychainEntryDivider)\(RedditCredential.refreshTokenKeychainLabel)"] = oldRefreshToken
      }
    }
    try? kc.remove("apiAppID")
    try? kc.remove("apiAppSecret")
    try? kc.remove("refreshToken")
    try? kc.remove("accessToken")
    
    let keychainKeys = kc.allKeys()
    var newCredentials: [String:RedditCredential] = [:]
    
    keychainKeys.forEach { key in
      let parts = key.split(separator: Self.keychainEntryDivider)
      if parts.count < 2 {
        try? kc.remove(key)
        return
      }
      let apiAppID = String(parts[0])
      let entryType = String(parts[1])
      if let entryValue = Self.keychain[key] {
        var cred = newCredentials[apiAppID] ?? RedditCredential(apiAppID: apiAppID)
        if entryType == RedditCredential.secretTokenKeychainLabel {
          let decoder = JSONDecoder()
          if let secretToken = try? decoder.decode(RedditCredential.SecretToken.self, from: entryValue.data(using: .utf8)!) {
            cred.secretToken = secretToken
          }
        } else if entryType == RedditCredential.refreshTokenKeychainLabel {
          cred.refreshToken = entryValue
        }
        newCredentials[apiAppID] = cred
      }
    }
    
    self.init(Array(newCredentials.values))
    
    self.cancelables.append(Defaults.observe(.redditCredentialSelectedID) { _ in
      self.objectWillChange.send()
    })
  }
    
  func setCredential(apiAppID: String, apiAppSecret: String? = nil, accessToken: String? = nil, refreshToken: String? = nil, expiration: Int? = nil, lastRefresh: Date? = nil) {
    let prefix = "\(apiAppID)\(Self.keychainEntryDivider)"
    let kc = RedditCredentialsManager.keychain
    if let apiAppSecret = apiAppSecret { kc["\(prefix)\(RedditCredential.apiAppSecretKeychainLabel)"] = apiAppSecret }
    var credential = RedditCredentialsManager.shared.credentials.first { $0.id == apiAppID } ?? RedditCredential(apiAppID: apiAppID)
    if let accessToken = credential.secretToken?.token ?? accessToken {
      var newSecretToken = credential.secretToken ?? .init(token: accessToken)
      if let expiration = expiration { newSecretToken.expiration = expiration }
      if let lastRefresh = lastRefresh { newSecretToken.lastRefresh = lastRefresh }
      credential.secretToken = newSecretToken
    }
    if let refreshToken = refreshToken { kc["\(prefix)\(RedditCredential.refreshTokenKeychainLabel)"] = refreshToken }
  }
  
  private init(_ credentials: [RedditCredential]) {
    self.credentials = credentials
  }
  
  deinit { self.cancelables.forEach { obs in obs.invalidate() } }
  
  func reset() {
    self.credentials.removeAll()
    try? Self.keychain.removeAll()
  }
}
