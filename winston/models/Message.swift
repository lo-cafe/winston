//
//  Message.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation

typealias Message = GenericRedditEntity<MessageData>

extension Message {
  convenience init(data: T, api: RedditAPI) {
    self.init(data: data, api: api, typePrefix: "t1_")
  }
  convenience init(id: String, api: RedditAPI) {
    self.init(id: id, api: api, typePrefix: "t1_")
  }
  
  func read() async -> Bool {
    if let fullname = data?.name {
      let result = await redditAPI.readMessage(fullname)
      return result ?? false
    }
    return false
  }
}

struct MessageData: GenericRedditEntityDataType {
    let first_message: String?
    let first_message_name: String?
    let subreddit: String?
    let likes: Int?
    let replies: String?
    let author_fullname: String?
    let id: String
    let subject: String?
    let associated_awarding_id: String?
    let score: Int?
    let author: String?
    let num_comments: Int?
    let parent_id: String?
    let subreddit_name_prefixed: String?
    let new: Bool?
    let type: String?
    let body: String?
    let link_title: String?
    let dest: String?
    let was_comment: Bool?
    let body_html: String?
    let name: String?
    let created: Double?
    let created_utc: Double?
    let context: String?
    let distinguished: String?
}

func getPostId(from urlString: String) -> String? {
    let pathComponents = urlString.components(separatedBy: "/")
    guard pathComponents.count > 2 else { return nil }
    return pathComponents[4]
}

