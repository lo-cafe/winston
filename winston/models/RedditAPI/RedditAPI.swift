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
  static let apiURLBase = "https://oauth.reddit.com"
  static let appClientID: String = "slCYQaTCGfV7FE38BxOeJw"
  static let appRedirectURI: String = "https://app.winston.lo.cafe/auth-success"
  
  @Published var loggedUser: UserCredential = UserCredential()
  @Published var lastAuthState: String?
  
  func getRequestHeaders() -> HTTPHeaders? {
    if let accessToken = self.loggedUser.accessToken {
      let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)",
        "User-Agent": "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)"
      ]
      return headers
    }
    return nil
  }
  
  func refreshToken() async -> Void {
    if let refreshToken = loggedUser.accessToken {
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
  
  func fetchSubs() async -> Void {
    await refreshToken()
    if let accessToken = self.loggedUser.accessToken {
      let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)",
        "User-Agent": "ios:lo.cafe.winston:v0.1.0 (by /u/Kinark)"
      ]
      
      let params = ["limit": 100, "count": 0]
      
      let response = await AF.request("\(RedditAPI.apiURLBase)/subreddits/mine/subscriber",
                                      method: .get,
                                      parameters: params,
                                      encoder: URLEncodedFormParameterEncoder(destination: .queryString),
                                      headers: headers
      )
        .serializingDecodable(Listing<SubredditData>.self).response
      switch response.result {
      case .success(let data):
        await MainActor.run {
          if let children = data.data?.children {
            Defaults[.subreddits] = children
          }
        }
        return
      case .failure(let error):
        print(error)
        return
      }
    } else {
      return
    }
  }
  
  func fetchSubPosts(_ url: String, sort: SubListingSortOption = .hot, after: String? = nil) async -> ([ListingChild<PostData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = FetchSubsPayload(limit: 15, count: 0, after: after)
      
      let response = await AF.request("\(RedditAPI.apiURLBase)\(url)\(sort.rawVal.value)/.json",
                                      method: .get,
                                      parameters: params,
                                      encoder: URLEncodedFormParameterEncoder(destination: .queryString),
                                      headers: headers
      )
        .serializingDecodable(Listing<PostData>.self).response
      switch response.result {
      case .success(let data):
        return (data.data?.children, data.data?.after)
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  func fetchPostComments(subreddit: String, postID: String, sort: CommentSortOption = .confidence) async -> ([ListingChild<CommentData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = FetchPostCommentsPayload(sort: sort.rawVal.value, limit: 100, depth: 1)
      
      let response = await AF.request("\(RedditAPI.apiURLBase)/r/\(subreddit)/comments/\(postID)/.json",
                                      method: .get,
                                      parameters: params,
                                      encoder: URLEncodedFormParameterEncoder(destination: .queryString),
                                      headers: headers
      )
        .serializingDecodable(FetchPostCommentsResponse.self).response
      switch response.result {
      case .success(let data):
        switch data[1] {
        case .a(_):
          return nil
        case .b(let actualData):
          return (actualData.data?.children, actualData.data?.after)
        }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  typealias FetchPostCommentsResponse = [Either<Listing<SubredditData>, Listing<CommentData>>]
  
//  struct FetchPostCommentsResponse: Codable {
//    var sort: String
//    var limit: Int
//    var depth: Int
//  }
  
  struct FetchPostCommentsPayload: Codable {
    var sort: String
    var limit: Int
    var depth: Int
  }
  
  struct FetchSubsPayload: Codable {
    var limit: Int
    var count: Int
    var after: String?
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

struct ListingChild<T: Codable>: Codable, Defaults.Serializable {
  let kind: String
  let data: T
}

struct Listing<T: Codable>: Codable, Defaults.Serializable {
  let kind: String
  let data: ListingData<T>?
}

struct ListingData<T: Codable>: Codable, Defaults.Serializable {
  let after: String?
  let dist: Int?
  let modhash: String?
  let geo_filter: String?
  let children: [ListingChild<T>]?
}

enum Either<A: Codable, B: Codable>: Codable {
    case a(A)
    case b(B)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(A.self) {
            self = .a(value)
            return
        }
        if let value = try? container.decode(B.self) {
            self = .b(value)
            return
        }
        throw DecodingError.typeMismatch(Either.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .a(let value):
            try container.encode(value)
        case .b(let value):
            try container.encode(value)
        }
    }
}
