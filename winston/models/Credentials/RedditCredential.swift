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
  enum CodingKeys: String, CodingKey { case id, apiAppID, apiAppSecret, accessToken, refreshToken, userName, profilePicture, _userAgent }
  
  var id: UUID
  var apiAppID: String { willSet { if apiAppID != newValue { clearIdentity() } } }
  var apiAppSecret: String { willSet { if apiAppSecret != newValue { clearIdentity() } } }
  var accessToken: AccessToken? = nil
  var refreshToken: String? = nil
  var userName: String? = nil
  var _userAgent: String? = nil
  var userAgent: String {
    get {
      _userAgent ?? "ios:lo.cafe.winston:v0.1.0 (by /u/\(userName ?? "UnknownUser"))"
    }
    set {
      _userAgent = newValue
    }
  }
  var profilePicture: String? = nil
  func isInKeychain() -> Bool { RedditCredentialsManager.shared.credentials.contains { $0.id == self.id } }
  var validationStatus: CredentialValidationState {
    var newRedditAPIPairState: CredentialValidationState = .empty
    
    if self.apiAppID.count == 22 && self.apiAppSecret.count == 30 {
      newRedditAPIPairState = .valid
    } else if self.apiAppID.count > 10 && self.apiAppSecret.count > 20 {
      newRedditAPIPairState = .maybeValid
    } else if self.apiAppID.count > 0 || self.apiAppSecret.count > 0 {
      newRedditAPIPairState = .invalid
    }
    
    guard self.refreshToken != nil else { return newRedditAPIPairState }
    return .authorized
  }
  
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
  
  enum CredentialValidationState: String {
    case authorized, valid, invalid, maybeValid, empty
    
    func getMeta() -> Meta {
        return switch self {
        case .authorized: .init(color: .green, lottieIcon: "thumbup", label: "Perfect", description: "This means you can use this account normally.")
        case .maybeValid, .valid: .init(color: .orange, lottieIcon: "warning-appear", label: "Unauthorized", description: "This means you need to allow your credentials to access your account.")
        case .empty, .invalid: .init(color: .red, lottieIcon: "thumbdown", label: "Invalid", description: "This means that you credential info is wrong.")
        }
      }
    
    struct Meta: Equatable {
      let color: Color
      let lottieIcon: String
      let label: String
      let description: String
    }
  }
}
