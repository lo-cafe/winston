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
import Combine

class RedditAPI: ObservableObject {
  static let shared = RedditAPI()
  static let winstonAPIBase = "https://winston.lo.cafe/api"
  static let redditApiURLBase = "https://oauth.reddit.com"
  static let redditWWWApiURLBase = "https://www.reddit.com"
  static let appClientID: String = "slCYQaTCGfV7FE38BxOeJw"
  static let appRedirectURI: String = "https://winston.cafe/auth-success"
  
  @Published var loggedUser: UserCredential = UserCredential()
  @Published var lastAuthState: String?
  @Published var me: User?
  
  // This is a replacement for getRequestHeader. We need to replace every instance of the former by this one
  func fetchRequestHeaders(force: Bool = false, includeAuth: Bool = true) async -> HTTPHeaders {
    var headers: HTTPHeaders = [
      "User-Agent": Defaults[.redditAPIUserAgent]
    ]
    if includeAuth, let selectedCredential = RedditCredentialsManager.shared.selectedCredential, let accessToken = await selectedCredential.getUpToDateToken(forceRenew: force) {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    return headers
  }
  
  func doRequest<D: Decodable, P: Encodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, params: P? = nil, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, decodable: D.Type, attempt: Int = 0) async -> Result<D, AFError> {
    let headers = await fetchRequestHeaders(includeAuth: authenticated)
    let req = AF.request(url, method: method, parameters: params, encoder: URLEncodedFormParameterEncoder(destination: paramsLocation), headers: headers, interceptor: nil, requestModifier: nil)

    let response = await req.serializingDecodable(decodable).response
    if attempt < 3, case .failure(_) = response.result {
      return await doRequest(url, authenticated: authenticated, method: method, params: params, paramsLocation: paramsLocation, decodable: decodable, attempt: attempt + 1)
    }
    return response.result
  }
  
  func doRequest<D: Decodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, decodable: D.Type, attempt: Int = 0) async -> Result<D, AFError> {
    let headers = await fetchRequestHeaders(includeAuth: authenticated)
    let req = AF.request(url, method: method, headers: headers, interceptor: nil, requestModifier: nil)

    let response = await req.serializingDecodable(decodable).response
    if attempt < 3, case .failure(_) = response.result {
      return await doRequest(url, authenticated: authenticated, method: method, decodable: decodable, attempt: attempt + 1)
    }
    return response.result
  }
  
  func doRequest<P: Encodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, params: P, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, attempt: Int = 0) async -> Result<String, AFError> {
    let req = await AF.request(url, method: method, parameters: params, encoder: URLEncodedFormParameterEncoder(destination: paramsLocation), headers: fetchRequestHeaders(includeAuth: authenticated))
    let result = await req.serializingString().result
    if attempt < 3, case .failure(_) = result {
      return await doRequest(url, authenticated: authenticated, method: method, params: params, paramsLocation: paramsLocation, attempt: attempt + 1)
    }
    return result
  }
  
  func doRequest(_ url: String, authenticated: Bool = true, method: HTTPMethod, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, attempt: Int = 0) async -> Result<String, AFError> {
    let req = await AF.request(url, method: method, headers: fetchRequestHeaders(includeAuth: authenticated))
    let result = await req.serializingString().result
    if attempt < 3, case .failure(_) = result {
      return await doRequest(url, authenticated: authenticated, method: method, attempt: attempt + 1)
    }
    return result
  }
  
  func getAccessToken(_ apiAppID: String, _ apiAppSecret: String, authCode: String, callback: ((Bool) -> Void)? = nil) async {
    let headers = await fetchRequestHeaders(includeAuth: false)
      var code = authCode
      if code.hasSuffix("#_") {
        code = "\(code.dropLast(2))"
      }
      let payload = GetAccessTokenPayload(code: authCode)
        AF.request(
          "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
          method: .post,
          parameters: payload,
          encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
          headers: headers)
        .authenticate(username: apiAppID, password: apiAppSecret)
        .responseDecodable(of: GetAccessTokenResponse.self) { response in
          switch response.result {
          case .success(let data):
            RedditCredentialsManager.shared.setCredential(apiAppID: apiAppID, apiAppSecret: apiAppSecret, accessToken: data.access_token, refreshToken: data.refresh_token, expiration: data.expires_in, lastRefresh: Date())
            Task(priority: .low) {
              _ = await self.fetchMe(force: true)
              _ = await self.fetchSubs()
              _ = await self.fetchMyMultis()
            }
            callback?(true)
            //        self.loggedUser = UserCredential(accessToken: data.token, refreshToken: data.refresh, expiration: data.expires)
            break
          case .failure(let error):
            print(error)
            
            
            //            var errorString: String?
            //            if let data = response.data {
            //              if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            //                errorString = json["error"]
            //              }
            //            }
            
            //            print(errorString)
            
            callback?(false)
            break
          }
        }
  }
  
  func monitorAuthCallback(_ apiAppID: String, _ apiAppSecret: String, _ rawUrl: URL, callback: ((Bool) -> Void)? = nil) async {
    if let url = URL(string: rawUrl.absoluteString.replacingOccurrences(of: "winstonapp://", with: "https://winston.cafe/")), url.lastPathComponent == "auth-success", let query = URLComponents(url: url, resolvingAgainstBaseURL: false), let state = query.queryItems?.first(where: { $0.name == "state" })?.value, let code = query.queryItems?.first(where: { $0.name == "code" })?.value, state == lastAuthState {
      await getAccessToken(apiAppID, apiAppSecret, authCode: code, callback: callback)
      lastAuthState = nil
    } else {
      callback?(false)
    }
  }
  
  func getAuthorizationCodeURL(_ appID: String) -> URL {
    let response_type: String = "code"
    let state: String = UUID().uuidString
    let redirect_uri: String = RedditAPI.appRedirectURI
    let duration: String = "permanent"
    let scope: String = "identity edit flair history modconfig modflair modlog modposts modwiki mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread"
    
    lastAuthState = state
    
    return URL(string: "https://www.reddit.com/api/v1/authorize?client_id=\(appID.trimmingCharacters(in: .whitespaces))&response_type=\(response_type)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  struct RefreshAccessTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
  }
  
  struct GetAccessTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let scope: String
    let expires_in: Int
  }
  
  struct RefreshAccessTokenPayload: Encodable {
    let grant_type = "refresh_token"
    let refresh_token: String
  }
  
  struct GetAccessTokenPayload: Encodable {
    let grant_type = "authorization_code"
    let code: String
    let redirect_uri = "https://winston.cafe/auth-success"
  }
  
  struct UserCredential: Hashable {
    static func == (lhs: RedditAPI.UserCredential, rhs: RedditAPI.UserCredential) -> Bool {
      lhs.hashValue == rhs.hashValue
    }
    
    let credentialsKeychain = Keychain(service: "lo.cafe.winston.reddit-credentials").synchronizable(Defaults[.syncKeyChainAndSettings])
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(modhash)
      hasher.combine(apiAppID)
      hasher.combine(apiAppSecret)
      hasher.combine(accessToken)
      hasher.combine(refreshToken)
      hasher.combine(expiration)
      hasher.combine(lastRefresh)
    }
    
    var modhash: String?
    var apiAppID: String? {
      didSet {
        credentialsKeychain["apiAppID"] = apiAppID
      }
    }
    var apiAppSecret: String? {
      didSet {
        credentialsKeychain["apiAppSecret"] = apiAppSecret
      }
    }
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
    
    init(apiAppID: String? = nil, apiAppSecret: String? = nil, accessToken: String? = nil, refreshToken: String? = nil, expiration: Int? = nil) {
      self.apiAppID = apiAppID ?? credentialsKeychain["apiAppID"]
      self.apiAppSecret = apiAppSecret ?? credentialsKeychain["apiAppSecret"]
      self.refreshToken = refreshToken ?? credentialsKeychain["refreshToken"]
      self.accessToken = self.refreshToken == nil ? nil : (accessToken ?? credentialsKeychain["accessToken"])
      if let expiration = expiration {
        self.expiration = expiration
      }
      self.lastRefresh = self.refreshToken == nil ? nil : (Defaults[.redditAPILastTokenRefreshDate] ?? Date(seconds: Date().timeIntervalSince1970 - Double(self.expiration ?? 86400 * 10)))
    }
  }
  
}

struct ListingChild<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let kind: String?
  var data: T?
}

struct Listing<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let kind: String?
  var data: ListingData<T>?
}

struct ListingData<T: Codable & Hashable>: Codable, Defaults.Serializable, Hashable {
  let after: String?
  let dist: Int?
  let modhash: String?
  let geo_filter: String?
  var children: [ListingChild<T>]?
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

