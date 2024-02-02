//
//  PostWinstonData.swift
//  winston
//
//  Created by Igor Marcossi on 26/01/24.
//

import SwiftUI
import Nuke

@Observable
class PostWinstonData: Hashable {
  static func == (lhs: PostWinstonData, rhs: PostWinstonData) -> Bool { lhs.permaURL == rhs.permaURL }
  
  var permaURL: URL? = nil
  var extractedMedia: MediaExtractedType? = nil
  var extractedMediaForcedNormal: MediaExtractedType? = nil
  var _strongSubreddit: Subreddit?
  weak var _weakSubreddit: Subreddit?
  var subreddit: Subreddit? {
    get { _weakSubreddit ?? _strongSubreddit }
    set { _weakSubreddit = newValue }
  }
  var mediaImageRequest: [ImageRequest] = []
  var avatarImageRequest: ImageRequest? = nil
  var postDimensions: PostDimensions = .zero
  var postDimensionsForcedNormal: PostDimensions = .zero
  var titleAttr: NSAttributedString?
  var linkMedia: PreviewModel?
  var videoMedia: SharedVideo?
  var postBodyAttr: NSAttributedString?
  var media: PostWinstonDataMedia?
  var seenCommentsCount: Int? = nil
  var seenComments: String? = nil
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(permaURL)
    //    hasher.combine(extractedMedia)
    hasher.combine(subreddit)
    hasher.combine(postDimensions)
    hasher.combine(titleAttr)
    hasher.combine(postBodyAttr)
  }
}

enum PostWinstonDataMedia {
  case link(PreviewModel)
  case video(SharedVideo)
  case imgs([ImageRequest])
  case yt(YTMediaExtracted)
  case repost(Post)
  case post(id: String, subreddit: String)
  case comment(id: String, postID: String, subreddit: String)
  case subreddit(name: String)
  case user(username: String)
}
