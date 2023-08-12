//
//  File.swift
//  winston
//
//  Created by Igor Marcossi on 28/07/23.
//

import Foundation
import SwiftUI
import YouTubePlayerKit


struct PreviewLink: View {
  var url: String
  var compact = false
  var redditURL: RedditURLType
  var media: Either<SecureMediaRedditVideo, SecureMediaAlt>?
  var contentWidth: CGFloat
  
  init(_ url: String, compact: Bool = false, contentWidth: CGFloat, media: Either<SecureMediaRedditVideo, SecureMediaAlt>?) {
    self.url = url.hasPrefix("http") ? url : "https://www.reddit.com\(url)"
    self.compact = compact
    self.media = media
    self.contentWidth = contentWidth
    self.redditURL = parseRedditURL(self.url)
    switch self.redditURL {
    case .other(let link):
      if PreviewLinkCache.shared.cache[link].isNil {
        PreviewLinkCache.shared.cache[link] = PreviewViewModel(link)
      }
    default:
      break
    }
  }
  
  var body: some View {
    switch redditURL {
    case .youtube(let videoId):
      if let media = media {
        PreviewYTLink(player: YouTubePlayer(source: .video(id: videoId)), url: url, media: media, contentWidth: contentWidth)
      }
    case .other(let link):
      PreviewLinkContent(viewModel: PreviewLinkCache.shared.cache[link]!, url: URL(string: link)!)
    default:
      PreviewRedditLinkContent(thing: redditURL)
    }
  }
}
