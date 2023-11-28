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
  static let appRedirectURI: String = "https://winston.cafe/auth-success"
  
  @Published var loggedUser: UserCredential = UserCredential()
  var lastAuthState: String?
  @Published var me: User?
  
  // This is a replacement for getRequestHeader. We need to replace every instance of the former by this one
  func fetchRequestHeaders(force: Bool = false, includeAuth: Bool = true, altCredential: RedditCredential? = nil, saveToken: Bool = true) async -> HTTPHeaders {
    var headers: HTTPHeaders = [
      "User-Agent": Defaults[.redditAPIUserAgent]
    ]
    if includeAuth, let selectedCredential = altCredential ?? RedditCredentialsManager.shared.selectedCredential, let accessToken = await selectedCredential.getUpToDateToken(forceRenew: force, saveToken: saveToken) {
      headers["Authorization"] = "Bearer \(accessToken.token)"
    }
  
    for (protectionSpace, credentials) in URLCredentialStorage.shared.allCredentials {
        for (_, credential) in credentials {
          URLCredentialStorage.shared.remove(credential, for: protectionSpace)
        }
    }
    HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)    
    
    return headers
  }
  
  private let reqAttempts = 2
  
  private let reqModifier: Session.RequestModifier = { urlReq in
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
  }
  
  func doRequest<D: Decodable, P: Encodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, params: P? = nil, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, decodable: D.Type, altCredential: RedditCredential? = nil, attempt: Int = 0, saveToken: Bool = true) async -> Result<D, AFError> {

    let headers = await fetchRequestHeaders(includeAuth: authenticated, altCredential: altCredential, saveToken: saveToken)
    let req = AF.request(url, method: method, parameters: params, encoder: URLEncodedFormParameterEncoder(destination: paramsLocation), headers: headers, requestModifier: reqModifier)
    
    let response = await req.serializingDecodable(decodable).response
    if attempt < reqAttempts, case .failure(_) = response.result {
      try? await Task.sleep(until: .now + .seconds(0.1), clock: .continuous)
      return await doRequest(url, authenticated: authenticated, method: method, params: params, paramsLocation: paramsLocation, decodable: decodable, altCredential: altCredential, attempt: attempt + 1, saveToken: saveToken)
    }
    return response.result
  }
  
  func doRequest<D: Decodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, decodable: D.Type, altCredential: RedditCredential? = nil, attempt: Int = 0, saveToken: Bool = true) async -> Result<D, AFError> {
    let headers = await fetchRequestHeaders(includeAuth: authenticated, altCredential: altCredential, saveToken: saveToken)
    let req = AF.request(url, method: method, headers: headers, requestModifier: reqModifier)

    let response = await req.serializingDecodable(decodable).response
    if attempt < reqAttempts, case .failure(_) = response.result {
      try? await Task.sleep(until: .now + .seconds(0.1), clock: .continuous)
      return await doRequest(url, authenticated: authenticated, method: method, decodable: decodable, altCredential: altCredential, attempt: attempt + 1, saveToken: saveToken)
    }
    return response.result
  }
  
  func doRequest<P: Encodable>(_ url: String, authenticated: Bool = true, method: HTTPMethod, params: P, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, altCredential: RedditCredential? = nil, attempt: Int = 0, saveToken: Bool = true) async -> Result<String, AFError> {
    let headers = await fetchRequestHeaders(includeAuth: authenticated, altCredential: altCredential, saveToken: saveToken)
    let req = AF.request(url, method: method, parameters: params, encoder: URLEncodedFormParameterEncoder(destination: paramsLocation), headers: headers, requestModifier: reqModifier)
    let result = await req.serializingString().result
    if attempt < reqAttempts, case .failure(_) = result {
      return await doRequest(url, authenticated: authenticated, method: method, params: params, paramsLocation: paramsLocation, altCredential: altCredential, attempt: attempt + 1, saveToken: saveToken)
    }
    return result
  }
  
  func doRequest(_ url: String, authenticated: Bool = true, method: HTTPMethod, paramsLocation: URLEncodedFormParameterEncoder.Destination = .httpBody, altCredential: RedditCredential? = nil, attempt: Int = 0, saveToken: Bool = true) async -> Result<String, AFError> {
    let headers = await fetchRequestHeaders(includeAuth: authenticated, altCredential: altCredential, saveToken: saveToken)
    let req = AF.request(url, method: method, headers: headers)
    let result = await req.serializingString().result
    if attempt < reqAttempts, case .failure(_) = result {
      return await doRequest(url, authenticated: authenticated, method: method, paramsLocation: paramsLocation, altCredential: altCredential, attempt: attempt + 1, saveToken: saveToken)
    }
    return result
  }
  
  func injectFirstAccessTokenInto(_ credential: inout RedditCredential, authCode: String) async -> Bool {
    if !credential.apiAppID.isEmpty && !credential.apiAppSecret.isEmpty {
      let headers = await fetchRequestHeaders(includeAuth: false)
      var code = authCode
      if code.hasSuffix("#_") {
        code = "\(code.dropLast(2))"
      }
      let payload = GetAccessTokenPayload(code: authCode)
      let response = await AF.request(
        "\(RedditAPI.redditWWWApiURLBase)/api/v1/access_token",
        method: .post,
        parameters: payload,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      )
        .authenticate(username: credential.apiAppID, password: credential.apiAppSecret, persistence: .none)
        .serializingDecodable(GetAccessTokenResponse.self).response
      switch response.result {
      case .success(let data):
        let newAcessToken = RedditCredential.AccessToken(token: data.access_token, expiration: data.expires_in, lastRefresh: Date())
        credential.refreshToken = data.refresh_token
        credential.accessToken = newAcessToken
        if let meData = await self.fetchMe(force: true, altCredential: credential, saveToken: false) {
          credential.userName = meData.name
          if let avatar = (meData.subreddit?.icon_img ?? meData.icon_img ?? meData.snoovatar_img), let rootAvatar = rootURL(avatar)?.absoluteString {
            credential.profilePicture = rootAvatar
          }
          return true
        }
//              Task(priority: .low) {
//                _ = await self.fetchSubs()
//                _ = await self.fetchMyMultis()
//              }
        return true
      case .failure(let error):
        print(error)
        return false
      }
    }
    return false
  }
  
  func monitorAuthCallback( credential: inout RedditCredential, _ rawUrl: URL) async -> Bool {
    if let url = URL(string: rawUrl.absoluteString.replacingOccurrences(of: "winstonapp://", with: "https://winston.cafe/")), url.lastPathComponent == "auth-success", let query = URLComponents(url: url, resolvingAgainstBaseURL: false), let state = query.queryItems?.first(where: { $0.name == "state" })?.value, let code = query.queryItems?.first(where: { $0.name == "code" })?.value, state == lastAuthState {
      let res = await injectFirstAccessTokenInto(&credential, authCode: code)
      lastAuthState = nil
      return res
    } else {
      return false
    }
  }
  
  func getAuthorizationCodeURL(_ appID: String) -> URL {
    let response_type: String = "code"
    let state: String = UUID().uuidString
    let redirect_uri: String = RedditAPI.appRedirectURI
    let duration: String = "permanent"
    let scope: String = "identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread"
    
    lastAuthState = state
    
    return URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=\(appID.trimmingCharacters(in: .whitespaces))&response_type=\(response_type)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
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

