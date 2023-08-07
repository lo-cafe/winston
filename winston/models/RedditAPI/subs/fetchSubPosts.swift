//
//  fetchSubPosts.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchSubPosts(_ id: String, sort: SubListingSortOption = .hot, after: String? = nil) async -> ([ListingChild<PostData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = FetchSubsPayload(limit: 15, after: after)
      var subID = id == "" ? "/" : id.hasPrefix("/r/") ? id : "/r/\(id)"
      subID = !subID.hasSuffix("/") ? "\(subID)/" : subID
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)\(subID)\(sort.rawVal.value)/.json",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<PostData>.self).response
      switch response.result {
      case .success(let data):
        //        if let modhash = data.data?.modhash {
        //          loggedUser.modhash = modhash
        //        }
        return (data.data?.children, data.data?.after)
      case .failure(let error):
        Oops.shared.sendError(error)
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
