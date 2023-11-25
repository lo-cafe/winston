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
  enum CodingKeys: String, CodingKey { case id, apiAppID, apiAppSecret, accessToken, refreshToken, userName, profilePicture }

  var id: UUID
  var apiAppID: String { willSet { if apiAppID != newValue { clearIdentity() } } }
  var apiAppSecret: String { willSet { if apiAppSecret != newValue { clearIdentity() } } }
  var accessToken: AccessToken? = nil
  var refreshToken: String? = nil
  var userName: String? = nil
  var profilePicture: String? = nil
  
  init(apiAppID: String = "", apiAppSecret: String = "", accessToken: String? = nil, refreshToken: String? = nil, expiration: Int? = nil, lastRefresh: Date? = nil, userName: String? = nil, profilePicture: String? = nil) {
    self.id = UUID()
    self.apiAppID = apiAppID
    self.apiAppSecret = apiAppSecret
    if let accessToken = accessToken, let expiration = expiration, let lastRefresh = lastRefresh {
      let newAccessToken = AccessToken(token: accessToken, expiration: expiration, lastRefresh: lastRefresh)
      self.accessToken = newAccessToken
    }
    self.refreshToken = refreshToken
    self.userName = userName
    self.profilePicture = profilePicture
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(UUID.self, forKey: .id)
    apiAppID = try values.decode(String.self, forKey: .apiAppID)
    apiAppSecret = try values.decode(String.self, forKey: .apiAppSecret)
    accessToken = try values.decodeIfPresent(AccessToken.self, forKey: .accessToken)
    refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
    userName = try values.decodeIfPresent(String.self, forKey: .userName)
    profilePicture = try values.decodeIfPresent(String.self, forKey: .profilePicture)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(id, forKey: .id)
    try container.encode(apiAppID, forKey: .apiAppID)
    try container.encode(apiAppSecret, forKey: .apiAppSecret)
    try container.encodeIfPresent(accessToken, forKey: .accessToken)
    try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
    try container.encodeIfPresent(userName, forKey: .userName)
    try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
  }
  
  mutating func clearIdentity() {
    accessToken = nil
    refreshToken = nil
    userName = nil
    profilePicture = nil
  }
  
  func save() {
    RedditCredentialsManager.shared.saveCred(self)
  }
  
  func getUpToDateToken(forceRenew: Bool = false, saveToken: Bool = true) async -> AccessToken? {
    guard let refreshToken = self.refreshToken, !apiAppID.isEmpty && !apiAppSecret.isEmpty else { return nil }
    if !forceRenew, let accessToken = self.accessToken {
      let lastRefresh = Double(accessToken.lastRefresh.timeIntervalSince1970)
      let expiration = Double(max(0, accessToken.expiration - 100))
      let now = Double(Date().timeIntervalSince1970)
      
      if now - lastRefresh < expiration {
        return accessToken
      }
    }
    return await fetchNewToken()
    
    func fetchNewToken(count: Int = 0) async -> AccessToken? {
      var headers = await RedditAPI.shared.fetchRequestHeaders(includeAuth: false)
      
      let payload = RedditAPI.RefreshAccessTokenPayload(refresh_token: refreshToken)
      let result = await AF.request(
        "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
        method: .post,
        parameters: payload,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      )
        .authenticate(username: apiAppID, password: apiAppSecret, persistence: .none)
        .serializingDecodable(RedditAPI.RefreshAccessTokenResponse.self).response.result
      switch result {
      case .success(let data):
        let newAccessToken = RedditCredential.AccessToken(token: data.access_token, expiration: data.expires_in, lastRefresh: Date())
        if saveToken {
          var newSelf = self
          newSelf.accessToken = newAccessToken
          RedditCredentialsManager.shared.saveCred(newSelf)
        }
        return newAccessToken
      case .failure(let error):
        if count < 3 {
          return await fetchNewToken(count: count + 1)
        }
        print(error)
        return nil
      }
    }
  }
  
  struct AccessToken: Equatable, Hashable, Codable {
    let token: String
    let expiration: Int
    let lastRefresh: Date
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
      if let encoded = cred.toStr() {
        RedditCredentialsManager.keychain[cred.id.uuidString] = encoded
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
      importedCredential = .init(apiAppID: oldApiAppID ?? "", apiAppSecret: oldApiAppSecret ?? "", refreshToken: oldRefreshToken)
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
      if let credStr = kc[key], let decodedCred = credStr.toObj(RedditCredential.self) {
        credentials.append(decodedCred)
      }
    }
      
    self.cancelables.append(Defaults.observe(.redditCredentialSelectedID) { _ in
      self.objectWillChange.send()
    })
  }
  
  func saveCred(_ cred: RedditCredential) {
    DispatchQueue.main.async {
      if let i = self.credentials.firstIndex(where: { $0.id == cred.id }) {
        self.credentials[i] = cred
      } else {
        self.credentials.append(cred)
      }
      Task(priority: .background) { self.syncCredentialsWithKeychain() }
    }
  }
  
  func deleteCred(_ cred: RedditCredential) {
    DispatchQueue.main.async {
      self.credentials = self.credentials.filter { $0.id != cred.id }
      self.syncCredentialsWithKeychain()
    }
  }
  
  deinit { self.cancelables.forEach { obs in obs.invalidate() } }
  
  func wipeAllCredentials() {
    DispatchQueue.main.async {
      self.credentials.removeAll()
      try? Self.keychain.removeAll()
    }
  }
}
