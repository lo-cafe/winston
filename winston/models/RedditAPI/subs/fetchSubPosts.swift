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
      let subID = buildSubID(id, sort, after, searchText)
      let limit = Defaults[.SubredditFeedDefSettings].chunkLoadSize
      let params = FetchSubsPayload(limit: limit, after: after)
      
      let urlString = "\(RedditAPI.redditApiURLBase)\(subID)".replacingOccurrences(of: " ", with: "%20")
      
      switch await self.doRequest(urlString, method: .get, params: params, paramsLocation: .queryString, decodable: Listing<PostData>.self)  {
      case .success(let data):
        return (data.data?.children, data.data?.after)
      case .failure(let error):
        print(error)
        return nil
      }
  }
  
  func fetchSavedPosts(_ id: String, after: String? = nil, searchText: String? = nil) async -> [Either<PostData, CommentData>]? {
    let subID = buildSubID(id, nil, after, searchText)
    let limit = Defaults[.SubredditFeedDefSettings].chunkLoadSize
    let params = FetchSubsPayload(limit: limit, after: after)
    
    let urlString = "\(RedditAPI.redditApiURLBase)\(subID)".replacingOccurrences(of: " ", with: "%20")
    
    switch await self.doRequest(urlString, method: .get, params: params, paramsLocation: .queryString, decodable: Listing<Either<PostData, CommentData>>.self)  {
    case .success(let data):
      return data.data?.children?.map { $0.data }.compactMap { $0 }
    case .failure(let error):
      print(error)
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
      subID += "&sort=\(Defaults[.SubredditFeedDefSettings].preferredSearchSort)"
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

