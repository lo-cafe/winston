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
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = FetchPostsPayload(id: postFullnames.joined(separator: ","))
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/info",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<PostData>.self).response
      switch response.result {
      case .success(let data):
        return data.data?.children?.compactMap { $0.data }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
//  typealias FetchPostCommentsResponse = [Either<Listing<PostData>, Listing<CommentData>>?]
  
  struct FetchPostsPayload: Codable {
    var id: String
  }
}
