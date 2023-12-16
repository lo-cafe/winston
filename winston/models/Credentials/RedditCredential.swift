//
//  RedditCredential.swift
//  winston
//
//  Created by Igor Marcossi on 05/12/23.
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
  var isAuthorized: Bool { refreshToken != nil }
  
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
  
  func save(_ forceCreate: Bool = true) {
    RedditCredentialsManager.shared.saveCred(self, forceCreate: forceCreate)
  }
  
  func delete() {
    RedditCredentialsManager.shared.deleteCred(self)
  }
  
  func getUpToDateToken(forceRenew: Bool = false, saveToken: Bool = true) async -> AccessToken? {
    guard let refreshToken = self.refreshToken, !apiAppID.isEmpty && !apiAppSecret.isEmpty else { return nil }
//    print(refreshToken, forceRenew, self.accessToken)
    if !forceRenew, let accessToken = self.accessToken {
      let lastRefresh = Double(accessToken.lastRefresh.timeIntervalSince1970)
      let expiration = Double(max(0, accessToken.expiration - 100))
      let now = Double(Date().timeIntervalSince1970)
      
      if (now - lastRefresh) < expiration {
        return accessToken
      }
    }
    return await fetchNewToken()
    
    func fetchNewToken(count: Int = 0) async -> AccessToken? {
      let payload = RedditAPI.RefreshAccessTokenPayload(refresh_token: refreshToken)
      let result = await RedditAPI.shared._doRequest(authenticated: false) { headers in
        let result = await AF.request(
          "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
          method: .post,
          parameters: payload,
          encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
          headers: headers
        )
          .authenticate(username: apiAppID, password: apiAppSecret, persistence: .none)
          .validate()
          .serializingDecodable(RedditAPI.RefreshAccessTokenResponse.self).response.result
        return result
      }
      
      switch result {
      case .success(let data):
        let newAccessToken = RedditCredential.AccessToken(token: data.access_token, expiration: data.expires_in, lastRefresh: Date())
        if saveToken {
          var newSelf = self
          newSelf.accessToken = newAccessToken
          RedditCredentialsManager.shared.saveCred(newSelf, forceCreate: false)
        }
        return newAccessToken
      case .failure(let error):
        print("pipo", error, payload)
        switch error.responseCode {
        case 401:
          var selfCopy = self
          selfCopy.refreshToken = nil
          selfCopy.accessToken = nil
          selfCopy.userName = nil
          selfCopy.profilePicture = nil
          selfCopy.save(false)
        default:
          break
        }
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
