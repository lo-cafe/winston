//
//  fetchComments.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchPost(subreddit: String, postID: String, commentID: String? = nil, sort: CommentSortOption = .confidence) async -> FetchPostCommentsResponse? {
    let params = FetchPostCommentsPayload(sort: sort.rawVal.value, limit: 35, depth: 15)
    var specificComment = ""
    if let commentID = commentID {
      specificComment = "/comment/\(commentID.hasPrefix("t1_") ? String(commentID.dropFirst(3)) : commentID)"
    }
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/r/\(subreddit)/comments/\(postID.hasPrefix("t3_") ? String(postID.dropFirst(3)) : postID)\(specificComment).json", method: .get, params: params, paramsLocation: .queryString, decodable: FetchPostCommentsResponse.self)  {
    case .success(let data):
      return data
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  typealias FetchPostCommentsResponse = [Either<Listing<PostData>, Listing<CommentData>>?]
  
  struct FetchPostCommentsPayload: Codable {
    var sort: String
    var limit: Int
    var depth: Int
    var comment: String?
  }
}
