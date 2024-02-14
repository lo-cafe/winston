//
//  fetchUserOverview.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchUserOverview(_ userName: String, _ dataTypeFilter: String? = nil, _ after: String? = nil) async -> ([Either<PostData, CommentData>]?, String?)? {
    var endpoint: String
    
    if let dataTypeFilter = dataTypeFilter, !dataTypeFilter.isEmpty {
      if dataTypeFilter.lowercased() == "posts" {
        endpoint = "\(RedditAPI.redditApiURLBase)/user/\(userName)/submitted.json"
      } else if dataTypeFilter.lowercased() == "comments" {
        endpoint = "\(RedditAPI.redditApiURLBase)/user/\(userName)/comments.json"
      } else {
        print("Invalid dataTypeFilter")
        return nil
      }
    } else {
      endpoint = "\(RedditAPI.redditApiURLBase)/user/\(userName)/overview.json"
    }
    
    var urlComponents = URLComponents(string: endpoint)!
    
    if let after = after {
      urlComponents.queryItems = [URLQueryItem(name: "after", value: after)]
    }
    
    guard let requestURL = urlComponents.url else {
      print("Error: Unable to create a valid URL")
      return nil
    }
    
    switch await self.doRequest(requestURL.absoluteString, method: .get, decodable: Listing<Either<PostData, CommentData>>.self)  {
    case .success(let data):
      return (data.data?.children?.map { $0.data }.compactMap { $0 }, data.data?.after)
    case .failure(let error):
      print(error)
      return nil
    }
  }
}
