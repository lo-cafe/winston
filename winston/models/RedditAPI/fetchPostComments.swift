//
//  fetchPostComments.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchPostComments(subreddit: String, postID: String, sort: CommentSortOption = .confidence) async -> ([ListingChild<CommentData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = FetchPostCommentsPayload(sort: sort.rawVal.value, limit: 100, depth: 3)
      
      let response = await AF.request("\(RedditAPI.redditApiURLBase)/r/\(subreddit)/comments/\(postID).json",
                                      method: .get,
                                      parameters: params,
                                      encoder: URLEncodedFormParameterEncoder(destination: .queryString),
                                      headers: headers
      )
        .serializingDecodable(FetchPostCommentsResponse.self).response
      switch response.result {
      case .success(let data):
        if let second = data[1] {
          switch second {
          case .first(_):
            return nil
          case .second(let actualData):
            if let modhash = actualData.data?.modhash {
              loggedUser.modhash = modhash
            }
            return (actualData.data?.children, actualData.data?.after)
          }
        }
        return nil
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  typealias FetchPostCommentsResponse = [Either<Listing<PostData>, Listing<CommentData>>?]
  
  struct FetchPostCommentsPayload: Codable {
    var sort: String
    var limit: Int
    var depth: Int
  }
}
