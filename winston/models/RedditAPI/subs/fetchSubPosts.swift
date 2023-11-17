//
//  fetchSubPosts.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire
import Defaults

extension RedditAPI {
  func fetchSubPosts(_ id: String, sort: SubListingSortOption = .best, after: String? = nil, searchText: String? = nil) async -> ([ListingChild<PostData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let subID = buildSubID(id, sort, after, searchText)
      let limit = Defaults[.feedPostsLoadLimit]
      let params = FetchSubsPayload(limit: limit, after: after)
      
      let urlString = "\(RedditAPI.redditApiURLBase)\(subID)".replacingOccurrences(of: " ", with: "%20")
      
      let response = await AF.request(
        urlString,
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
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  func fetchSavedPosts(_ id: String, after: String? = nil, searchText: String? = nil) async -> [Either<PostData, CommentData>]? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let subID = buildSubID(id, nil, after, searchText)
      let limit = Defaults[.feedPostsLoadLimit]
      let params = FetchSubsPayload(limit: limit, after: after)
      
      let urlString = "\(RedditAPI.redditApiURLBase)\(subID)".replacingOccurrences(of: " ", with: "%20")
      
      print(urlString)
      
      let response = await AF.request(
        urlString,
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      ).serializingDecodable(Listing<Either<PostData, CommentData>>.self).response
      
      switch response.result {
      case .success(let data):
        return data.data?.children?.map { $0.data }.compactMap { $0 }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
    
  private func buildSubID(_ id: String, _ sort: SubListingSortOption?, _ after: String?, _ searchText: String?) -> String {
    let appendedFileType = ".json"
    var subID = ""
  
    if id != "saved" {
      subID = id == "" ? "/" : id.hasPrefix("/r/") ? id : "/r/\(id)"
    } else if let username = RedditAPI.shared.me?.data?.name {
      subID = "/user/\(username)/\(id)"
    } else {
      print("Sub ID failed to build. Invalid logic... content will fail to load.")
    }
    
    subID = !subID.hasSuffix("/") ? "\(subID)/" : subID
    
    if searchText != nil {
      subID += "search\(appendedFileType)"
    } else {
      if let sort = sort {
        switch sort {
        case .best:
          subID += "best\(appendedFileType)"
        case .hot:
          subID += "hot\(appendedFileType)"
        case .new:
          subID += "new\(appendedFileType)"
        case .top(let topSortOption):
          subID += "top\(appendedFileType)"
          subID += buildTopSortQuery(topSortOption)
        case .controversial:
          subID += "controversial\(appendedFileType)"
        }
      }
    }
    
    if let searchText = searchText {
      subID += subID.contains("?") ? "&q=\(searchText)" : "?q=\(searchText)"
      subID += "&restrict_sr=on"
      
      // Add preferred sort to search url
      subID += "&sort=\(Defaults[.preferredSearchSort])"
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

