//
//  submitPost.swift
//  winston
//
//  Created by Igor Marcossi on 24/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func submitPost(title: String, data postData: NewPostData, _ kind: PostType, sr: String) async -> SubmitPostResponseData? {
    let isGallery = postData.gallery != nil
    var payload = SubmitPostPayload(flair_id: postData.flair?.id, flair_text: postData.flair?.text, kind: kind, sr: sr, title: title, items: postData.gallery)
    if isGallery {
      payload.kind = nil
    }
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/\(!isGallery ? "submit" : "submit_gallery_post.json")?raw_json=1", method: .post, params: payload, decodable: SubmitPostResponse.self) {
    case .success(let data):
      return data.json.data
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  struct SubmitPostResponseData: Codable {
    let url: String
    let drafts_count: Int
    let id: String
    let name: String
  }
  
  struct SubmitPostResponseJSON: Codable {
    let errors: [String]
    let data: SubmitPostResponseData
  }
  
  struct SubmitPostResponse: Codable {
    let json: SubmitPostResponseJSON
  }
  
  struct SubmitPostPayload: Codable {
    var api_type = "json"
    var flair_id: String?
    var flair_text: String?
    var kind: PostType?
    var nsfw: Bool? = false
    var resubmit = true
    var richtext_json: String?
    var sendreplies: Bool = true
    var spoiler: Bool?
    var sr: String
    var text: String?
    var title: String
    var url: String?
    var items: [NewPostGalleryItem]?
    var raw_json = 1
  }
  
  enum PostType: String, Codable, CaseIterable {
    case link
    case text = "self"
    case image
    case video
//    case videogif
    
    var icon: String {
      switch self {
      case .link:
        return "link"
      case .text:
        return "text.cursor"
      case .image:
        return "photo"
      case .video:
        return "video.fill"
//      case .videogif:
//        return ""
      }
    }
  }
}
