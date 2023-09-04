//
//  fetchSubPosts.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchSubPosts(_ id: String, sort: SubListingSortOption = .best, after: String? = nil) async -> ([ListingChild<PostData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let subID = buildSubID(id, sort, after)

      let params = FetchSubsPayload(limit: 25, after: after)

      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)\(subID)",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
      .serializingDecodable(Listing<PostData>.self).response

      switch response.result {
      case .success(let data):
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

  private func buildSubID(_ id: String, _ sort: SubListingSortOption, _ after: String?) -> String {
    let appendedJson = ".json"
    
    var subID = id == "" ? "/" : id.hasPrefix("/r/") ? id : "/r/\(id)"
    subID = !subID.hasSuffix("/") ? "\(subID)/" : subID

    switch sort {
    case .best:
      subID += "best\(appendedJson)"
    case .hot:
      subID += "hot\(appendedJson)"
    case .new:
      subID += "new\(appendedJson)"
    case .top(let topSortOption):
      subID += "top\(appendedJson)"
      subID += buildTopSortQuery(topSortOption)
    }

    if id == "saved", let myName = me?.data?.name {
      subID = "/user/\(myName)/saved/"
    }

    if let after = after {
      subID += subID.contains("?") ? "&after=\(after)" : "?after=\(after)"
    }

    return subID
  }

  private func buildTopSortQuery(_ topSortOption: SubListingSortOption.TopListingSortOption) -> String {
    switch topSortOption {
    case .hour:
      return "?t=hour"
    case .day:
      return "?t=day"
    case .week:
      return "?t=week"
    case .month:
      return "?t=month"
    case .year:
      return "?t=year"
    case .all:
      return "?t=all"
    }
  }
}

