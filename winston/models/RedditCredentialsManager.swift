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
  enum CodingKeys: String, CodingKey { case id, apiAppID, keychainApiAppSecret, accessToken, refreshToken, userName, profilePicture }

  var id: UUID
  var apiAppID: String? = nil
  
  private var keychainApiAppSecret: String? = nil
  
  var apiAppSecret: String? {
    get {
      if let keychainApiAppSecret = self.keychainApiAppSecret { return keychainApiAppSecret }
      if let stringFromKeychain = getStringFromKeychain(), let data = stringFromKeychain.data(using: .utf8) {
        let decoder = JSONDecoder()
        return (try? decoder.decode(Self.self, from: data))?.keychainApiAppSecret
      }
      return nil
    }
    set {
      keychainApiAppSecret = newValue
    }
  }
  
  var accessToken: AccessToken? = nil
  var refreshToken: String? = nil
  var userName: String? = nil
  var profilePicture: String? = nil
  
  init(apiAppID: String? = nil, apiAppSecret: String? = nil, accessToken: String? = nil, refreshToken: String? = nil, expiration: Int? = nil, lastRefresh: Date? = nil, userName: String? = nil, profilePicture: String? = nil) {
    self.id = UUID()
    self.apiAppID = apiAppID
    self.apiAppSecret = apiAppSecret
    if let accessToken = accessToken {
      var newAccessToken = AccessToken(token: accessToken)
      newAccessToken.expiration = expiration
      newAccessToken.lastRefresh = lastRefresh
      self.accessToken = newAccessToken
    }
    self.refreshToken = refreshToken
    self.userName = userName
    self.profilePicture = profilePicture
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(UUID.self, forKey: .id)
    apiAppID = try values.decodeIfPresent(String.self, forKey: .apiAppID)
    accessToken = try values.decodeIfPresent(AccessToken.self, forKey: .accessToken)
    refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
    keychainApiAppSecret = try values.decodeIfPresent(String.self, forKey: .keychainApiAppSecret)
    userName = try values.decodeIfPresent(String.self, forKey: .userName)
    profilePicture = try values.decodeIfPresent(String.self, forKey: .profilePicture)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(apiAppID, forKey: .apiAppID)
    try container.encodeIfPresent(keychainApiAppSecret, forKey: .keychainApiAppSecret)
    try container.encodeIfPresent(accessToken, forKey: .accessToken)
    try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
    try container.encodeIfPresent(userName, forKey: .userName)
    try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
  }
  
  mutating func save() {
    self.refreshToken = nil
    self.accessToken = nil
    RedditCredentialsManager.shared.saveCred(self)
  }
  
  private func getStringFromKeychain() -> String? { return RedditCredentialsManager.keychain[self.id.uuidString] }
  
  private func getFromKeychain() -> Self? {
    if let str = getStringFromKeychain() {
      return Self.decodeString(str)
    }
    return nil
  }
  
  static func decodeString(_ str: String) -> Self? {
    if let data = str.data(using: .utf8) {
      let decoder = JSONDecoder()
      var decoded = try? decoder.decode(Self.self, from: data)
      decoded?.keychainApiAppSecret = nil
      return decoded
    }
    return nil
  }
  
  func getUpToDateToken(forceRenew: Bool = false, count: Int = 0) async -> String? {
    if
      let apiAppID = apiAppID,
      let refreshToken = self.refreshToken,
      let apiAppSecret = self.apiAppSecret,
        forceRenew ||
        Double(Date().timeIntervalSince1970 - ((self.accessToken?.lastRefresh ?? Date()).timeIntervalSince1970 - Double(self.accessToken?.expiration ?? 86400 * 10))) > Double(max(0, (self.accessToken?.expiration ?? 0) - 100))
    {
      let headers = await RedditAPI.shared.fetchRequestHeaders(includeAuth: false)
      let payload = RedditAPI.RefreshAccessTokenPayload(refresh_token: refreshToken)
      let result = await AF.request(
        "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
        method: .post,
        parameters: payload,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers)
        .authenticate(username: apiAppID, password: apiAppSecret)
        .serializingDecodable(RedditAPI.RefreshAccessTokenResponse.self).response.result
      switch result {
      case .success(let data):
        var selfCopy = self
        selfCopy.accessToken = .init(token: data.access_token, expiration: data.expires_in, lastRefresh: Date())
        if let myIndex = RedditCredentialsManager.shared.credentials.firstIndex(where: { $0.id == self.id }) {
          await MainActor.run { [selfCopy] in
            RedditCredentialsManager.shared.saveCred(selfCopy)
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
  
  struct AccessToken: Equatable, Hashable, Codable, Defaults.Serializable {
    let token: String
    var expiration: Int? = nil
    var lastRefresh: Date? = nil
  }
}


class RedditCredentialsManager: ObservableObject {
  static let shared = RedditCredentialsManager()
  static let keychainEntryDivider = "\\--(*.*)--/"
  static let oldKeychainServiceString = "lo.cafe.winston.reddit-credentials"
  static let keychainServiceString = "lo.cafe.winston.reddit-multi-credentials"
  static let keychain = Keychain(service: RedditCredentialsManager.keychainServiceString).synchronizable(Defaults[.syncKeyChainAndSettings])
  @Published private(set) var credentials: [RedditCredential] = []
  var cancelables: [Defaults.Observation] = []
  
  var selectedCredential: RedditCredential? {
    if credentials.count > 0 {
      return credentials.first { $0.id == Defaults[.redditCredentialSelectedID] } ?? credentials[0]
    }
    return nil
  }
  
  func syncCredentialsWithKeychain() {
    Self.keychain.allKeys().forEach { keychainCredID in
      if self.credentials.first(where: { $0.id.uuidString == keychainCredID }) == nil {
        try? Self.keychain.remove(keychainCredID)
      }
    }
    self.credentials.forEach { cred in
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(cred) {
        RedditCredentialsManager.keychain[cred.id.uuidString] = String(decoding: encoded, as: UTF8.self)
      }
    }
  }
  
  init() {
    let okc = Keychain(service: Self.oldKeychainServiceString)
    let kc = Self.keychain
    
    let oldApiAppID = okc["apiAppID"]
    let oldApiAppSecret = okc["apiAppSecret"]
    let oldRefreshToken = okc["refreshToken"]
    
    var importedCredential: RedditCredential? = nil
    if oldApiAppID != nil || oldApiAppSecret != nil || oldRefreshToken != nil {
      importedCredential = .init(apiAppID: oldApiAppID, apiAppSecret: oldApiAppSecret, refreshToken: oldRefreshToken)
    }
    
    if let importedCredential = importedCredential {
      credentials.append(importedCredential)
    }

    try? okc.remove("apiAppID")
    try? okc.remove("apiAppSecret")
    try? okc.remove("refreshToken")
    try? okc.remove("accessToken")
    
    let keychainKeys = kc.allKeys()
    
    keychainKeys.forEach { key in
      if let credStr = kc[key], let decodedCred = RedditCredential.decodeString(credStr) {
        credentials.append(decodedCred)
      }
    }
      
    self.cancelables.append(Defaults.observe(.redditCredentialSelectedID) { _ in
      self.objectWillChange.send()
    })
  }
  
  func saveCred(_ cred: RedditCredential) {
    if let i = self.credentials.firstIndex(where: { $0.id == cred.id }) {
      self.credentials[i] = cred
    } else {
      self.credentials.append(cred)
    }
    syncCredentialsWithKeychain()
  }
  
  func deleteCred(_ cred: RedditCredential) {
    self.credentials = self.credentials.filter { $0.id != cred.id }
    syncCredentialsWithKeychain()
  }
  
  deinit { self.cancelables.forEach { obs in obs.invalidate() } }
  
  func wipeAllCredentials() {
    self.credentials.removeAll()
    try? Self.keychain.removeAll()
  }
}
