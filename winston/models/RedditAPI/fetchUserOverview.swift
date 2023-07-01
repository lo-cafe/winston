//
//  fetchUserOverview.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchUserOverview(_ userName: String) async -> [Either<CommentData, PostData>]? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
    let response = await AF.request("\(RedditAPI.redditApiURLBase)/user/\(userName)/overview.json",
                                      method: .get,
                                      headers: headers
      )
        .serializingDecodable(Listing<Either<CommentData, PostData>>.self).response
      switch response.result {
      case .success(let data):
        return data.data?.children?.map { $0.data }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
