//
//  fetchSub.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchSub(_ name: String) async -> ListingChild<SubredditData>? {
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)\(name.hasPrefix("/r/") ? name : "/r/\(name)/")about.json", method: .get, decodable: ListingChild<SubredditData>.self)  {
    case .success(let data):
      return data
    case .failure(let error):
      print(error)
      return nil
    }
  }
}
