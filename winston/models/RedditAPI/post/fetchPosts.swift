//
//  fetchPosts.swift
//  winston
//
//  Created by Igor Marcossi on 25/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchPosts(postFullnames: [String]) async -> [PostData]? {
    let params = FetchPostsPayload(id: postFullnames.joined(separator: ","))
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/info", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<PostData>.self)  {
    case .success(let data):
      return data.data?.children?.compactMap { $0.data }
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  //  typealias FetchPostCommentsResponse = [Either<Listing<PostData>, Listing<CommentData>>?]
  
  struct FetchPostsPayload: Codable {
    var id: String
  }
}
