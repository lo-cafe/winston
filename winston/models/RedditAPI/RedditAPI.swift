//
//  RedditAPI.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import Foundation
import KeychainAccess
import Alamofire
import SwiftUI
import Defaults

class RedditAPI: ObservableObject {
  static let winstonAPIBase = "https://winston.lo.cafe/api"
  static let redditApiURLBase = "https://oauth.reddit.com"
  static let redditWWWApiURLBase = "https://www.reddit.com"
  static let appClientID: String = "slCYQaTCGfV7FE38BxOeJw"
  static let appRedirectURI: String = "https://app.winston.lo.cafe/auth-success"
  
  @Published var loggedUser: UserCredential = UserCredential()
  @Published var lastAuthState: String?
  
  func getRequestHeaders(includeAuth: Bool = true) -> HTTPHeaders? {
    if let accessToken = self.loggedUser.accessToken {
      var headers: HTTPHeaders = [
        "User-Agent": "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)"
      ]
      if includeAuth {
        headers["Authorization"] = "Bearer \(accessToken)"
      }
      return headers
    }
    return nil
  }
  
  func refreshToken() async -> Void {
    print("refresca")
    if let refreshToken = loggedUser.refreshToken {
      if loggedUser.lastRefresh!.timeIntervalSinceNow > Double(loggedUser.expiration ?? 0) {
        let payload = RefreshAccessTokenPayload(refreshToken: refreshToken)
        let response = await AF.request("\(RedditAPI.winstonAPIBase)/get-access-token",
                                        method: .post,
                                        parameters: payload,
                                        encoder: JSONParameterEncoder.default)
          .serializingDecodable(RefreshAccessTokenResponse.self).response
        switch response.result {
        case .success(let data):
          await MainActor.run {
            self.loggedUser.accessToken = data.token
            self.loggedUser.expiration = data.expires
          }
          return
        case .failure(_):
          return
        }
      } else {
        return
      }
    }
  }
  
  func getAccessToken(authCode: String) {
    var code = authCode
    if code.hasSuffix("#_") {
      code = "\(code.dropLast(2))"
    }
    let payload = GetAccessTokenPayload(code: authCode)
    AF.request("\(RedditAPI.winstonAPIBase)/get-access-token",
               method: .post,
               parameters: payload,
               encoder: JSONParameterEncoder.default)
    .responseDecodable(of: GetAccessTokenResponse.self) { response in
      switch response.result {
      case .success(let data):
        self.loggedUser.accessToken = data.token
        self.loggedUser.refreshToken = data.refresh
        self.loggedUser.expiration = data.expires
        //        self.loggedUser = UserCredential(accessToken: data.token, refreshToken: data.refresh, expiration: data.expires)
        break
      case .failure(_):
        break
      }
    }
  }
  
  func monitorAuthCallback(_ url: URL) {
    if url.lastPathComponent == "auth-success", let query = URLComponents(url: url, resolvingAgainstBaseURL: false), let state = query.queryItems?.first(where: { $0.name == "state" })?.value, let code = query.queryItems?.first(where: { $0.name == "code" })?.value {
      if state == lastAuthState {
        getAccessToken(authCode: code)
        lastAuthState = nil
      }
    }
  }
  
  func getAuthorizationCodeURL() -> URL {
    let client_id: String = RedditAPI.appClientID
    let response_type: String = "code"
    let state: String = UUID().uuidString
    let redirect_uri: String = RedditAPI.appRedirectURI
    let duration: String = "permanent"
    let scope: String = "identity edit flair history modconfig modflair modlog modposts modwiki mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread"
    
    lastAuthState = state
    
    return URL(string: "https://www.reddit.com/api/v1/authorize?client_id=\(client_id)&response_type=\(response_type)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  func getModHash() async {
    if loggedUser.modhash == nil {
      await fetchSubs()
    }
  }
  
  struct RefreshAccessTokenResponse: Decodable {
    let token: String
    let expires: Int
  }
  
  struct GetAccessTokenResponse: Decodable {
    let token: String
    let refresh: String
    let expires: Int
  }
  
  struct RefreshAccessTokenPayload: Encodable {
    let refreshToken: String
  }
  
  struct GetAccessTokenPayload: Encodable {
    let code: String
  }
  
  struct UserCredential {
    let credentialsKeychain = Keychain(service: "lo.cafe.winston.reddit-credentials")
    
    var modhash: String?
    var accessToken: String? {
      didSet {
        credentialsKeychain["accessToken"] = accessToken
      }
    }
    var refreshToken: String? {
      didSet {
        credentialsKeychain["refreshToken"] = refreshToken
      }
    }
    var expiration: Int? {
      get {
        Defaults[.redditAPITokenExpiration]
      }
      set {
        Defaults[.redditAPITokenExpiration] = newValue
      }
    }
    var lastRefresh: Date? {
      get {
        Defaults[.redditAPILastTokenRefreshDate]
      }
      set {
        Defaults[.redditAPILastTokenRefreshDate] = newValue
      }
    }
    var isSet: Bool {
      return accessToken != nil && refreshToken != nil && expiration != nil && lastRefresh != nil
    }
    
    init(accessToken: String? = nil, refreshToken: String? = nil, expiration: Int? = nil) {
      self.accessToken = accessToken ?? credentialsKeychain["accessToken"]
      self.refreshToken = refreshToken ?? credentialsKeychain["refreshToken"]
      if let expiration = expiration {
        self.expiration = expiration
      }
      self.lastRefresh = Date()
    }
  }
  
}

struct ListingChild<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let kind: String?
  let data: T
}

struct Listing<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let kind: String?
  let data: ListingData<T>?
}

struct ListingData<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let after: String?
  let dist: Int?
  let modhash: String?
  let geo_filter: String?
  let children: [ListingChild<T>]?
}

enum Either<A: Codable & Hashable, B: Codable & Hashable>: Codable, Hashable {
    case first(A)
    case second(B)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let firstType = try container.decode(A.self)
            self = .first(firstType)
        } catch let firstError {
            do {
                let secondType = try container.decode(B.self)
                self = .second(secondType)
            } catch let secondError {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type mismatch for both types.", underlyingError: Swift.DecodingError.typeMismatch(Any.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "First type error: \(firstError). Second type error: \(secondError)")))
                throw DecodingError.dataCorrupted(context)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .first(let value):
            try container.encode(value)
        case .second(let value):
            try container.encode(value)
        }
    }
}
