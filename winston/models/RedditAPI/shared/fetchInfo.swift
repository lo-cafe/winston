//
//  getInfo.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchInfo(fullnames: [String]) async -> FetchInfoResponse? {
    let params = FetchPostsPayload(id: fullnames.joined(separator: ","))
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/info", method: .get, params: params, paramsLocation: .queryString, decodable: FetchInfoResponse.self)  {
    case .success(let data):
      return data
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  //  typealias FetchPostCommentsResponse = [Either<Listing<PostData>, Listing<CommentData>>?]
  
  enum FetchInfoResponse: Codable, Hashable {
    case post(Listing<PostData>)
    case comment(Listing<CommentData>)
    case user(Listing<UserData>)
    case subreddit(Listing<SubredditData>)
    
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      
      do {
        let firstType = try container.decode(Listing<PostData>.self)
        self = .post(firstType)
      } catch let firstError {
        do {
          let secondType = try container.decode(Listing<CommentData>.self)
          self = .comment(secondType)
        } catch let secondError {
          do {
            let secondType = try container.decode(Listing<UserData>.self)
            self = .user(secondType)
          } catch let thirdError {
            do {
              let secondType = try container.decode(Listing<SubredditData>.self)
              self = .subreddit(secondType)
            } catch let fourthError {
              let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type mismatch for both types.", underlyingError: Swift.DecodingError.typeMismatch(Any.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "First type error: \(firstError). Second type error: \(secondError). Third type error: \(thirdError). Fourth type error: \(fourthError)")))
              throw DecodingError.dataCorrupted(context)
            }
          }
        }
      }
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .post(let value):
        try container.encode(value)
      case .comment(let value):
        try container.encode(value)
      case .user(let value):
        try container.encode(value)
      case .subreddit(let value):
        try container.encode(value)
      }
    }
  }
  
  struct FetchInfoPayload: Codable {
    var id: String
  }
}
