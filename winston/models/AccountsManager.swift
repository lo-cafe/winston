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

struct RedditCredential: Identifiable, Equatable, Hashable, Codable, Defaults.Serializable {
  static let secretTokenKeychainLabel = "secretToken"
  static let refreshTokenKeychainLabel = "refreshToken"
  var id: String { self.apiAppID }
  var apiAppID: String
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
  
  struct SecretToken: Equatable, Hashable, Codable, Defaults.Serializable {
    let token: String
    var expiration: Int? = nil
    var lastRefresh: Date? = nil
  }
}

class RedditCredentialsManager: ObservableObject {
  static let keychainEntryDivider = "\\--(*.*)--/"
  static let keychainService = "lo.cafe.winston.reddit-credentials"
  static let keychain = Keychain(service: RedditCredentialsManager.keychainService).synchronizable(Defaults[.syncKeyChainAndSettings])
  @Published var credentials: [RedditCredential]
  
  init() {
    let keychainKeys = RedditCredentialsManager.keychain.allKeys()

    var newCredentials: [String:RedditCredential] = [:]
    keychainKeys.forEach { key in
      let parts = key.split(separator: RedditCredentialsManager.keychainEntryDivider)
      let apiAppID = String(parts[0])
      let entryType = String(parts[1])
      if let entryValue = RedditCredentialsManager.keychain[key] {
        var cred = newCredentials[apiAppID] ?? RedditCredential(apiAppID: apiAppID)
        if entryType == "secretToken" {
          let decoder = JSONDecoder()
          if let secretToken = try? decoder.decode(RedditCredential.SecretToken.self, from: entryValue.data(using: .utf8)!) {
            cred.secretToken = secretToken
          }
        } else if entryType == "refreshToken" {
          cred.refreshToken = entryValue
        }
        newCredentials[apiAppID] = cred
      }
    }
    
    self.credentials = Array(newCredentials.values)
  }
}
