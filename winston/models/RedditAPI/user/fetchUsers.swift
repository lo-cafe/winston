//
//  fetchUsers.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import Foundation
import Alamofire
import SwiftUI

extension RedditAPI {
  func fetchUsers(_ ids: [String]) async -> MultipleUsersDictionary? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let payload = FetchUsersByIDPayload(ids: String(ids.joined(separator: ",")))
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/user_data_by_account_ids",
        method: .get,
        parameters: payload,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(MultipleUsersDictionary.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  func updateAvatarURLCacheFromOverview(subjects: [Either<PostData, CommentData>]) async {
    var namesArr: [String] = []
    subjects.forEach { subject in
      switch subject {
      case .first(let post):
        if let fullname = post.author_fullname {
          namesArr.append(fullname)
        }
      case .second(let comment):
        if let fullname = comment.author_fullname {
          namesArr.append(fullname)
        }
      }
    }
    await updateAvatarURL(names: namesArr)
  }
  
  func updateAvatarURLCacheFromComments(comments: [Comment]) async {
    let namesArr = getNamesFromComments(comments)
    await updateAvatarURL(names: namesArr)
  }
  
  func updateAvatarURLCacheFromPosts(posts: [Post]) async {
    let namesArr = posts.compactMap { $0.data?.author_fullname }
    await updateAvatarURL(names: namesArr)
  }
  
  func updateAvatarURL(names: [String]) async {
    if let data = await self.fetchUsers(names) {
      let newDict = data.mapValues { val in val.profile_img ?? "" }
      await MainActor.run { [newDict] in
        withAnimation {
          AvatarCache.shared.merge(newDict)
        }
      }
    }
  }
  
  struct FetchUsersByIDPayload: Codable {
    let ids: String
  }
  
  typealias MultipleUsersDictionary = [String: MultipleUsersUser]
  
  struct MultipleUsersUser: Codable {
      let name: String?
      let created_utc: Double?
      let link_karma: Int?
      let comment_karma: Int?
      let profile_img: String?
      let profile_color: String?
      let profile_over_18: Bool?
  }
}

func getNamesFromComments(_ comments: [Comment]? = nil, _ commentDatas: [CommentData]? = nil) -> [String] {
  var namesArr: [String] = []
  let actualComments = commentDatas ?? comments!.map { $0.data! }
  actualComments.forEach { comment in
    if let fullname = comment.author_fullname {
      namesArr.append(fullname)
    }
    switch comment.replies {
      case .first(_):
        break
      case .second(let listing):
        if let replies = listing.data?.children, replies.count > 0 {
          namesArr += getNamesFromComments(nil, replies.map { $0.data }.compactMap { $0 } )
        }
      case .none:
        break
      }
  }
  return namesArr
}
