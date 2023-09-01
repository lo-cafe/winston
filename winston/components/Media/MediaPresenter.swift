//
//  MediaPresenter.swift
//  winston
//
//  Created by Igor Marcossi on 22/08/23.
//

import SwiftUI
import YouTubePlayerKit
import Defaults

struct OnlyURL: View {
  @Default(.postLinkTitleSize) var postLinkTitleSize
  var url: URL
  @Environment(\.openURL) private var openURL
  var body: some View {
    HStack {
      Image(systemName: "link")
      Text(url.absoluteString.replacingOccurrences(of: "https://", with: ""))
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(Capsule(style: .continuous).fill(.blue))
    .fontSize(postLinkTitleSize - 2, .medium)
    .lineLimit(1)
    .fixedSize(horizontal: false, vertical: true)
    .foregroundColor(.white)
    .highPriorityGesture(TapGesture().onEnded {
      if let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://reddit.com/", with: "winstonapp://")) {
        openURL(newURL)
      }
    })
  }
}

struct MediaPresenter: View {
  var showURLInstead = false
  let media: MediaExtractedType
  let post: Post
  let compact: Bool
  let contentWidth: CGFloat
  
  var body: some View {
    switch media {
    case .image(let imgMediaExtracted):
      if !showURLInstead {
        ImageMediaPost(compact: compact, post: post, images: [imgMediaExtracted], contentWidth: contentWidth)
      }
    case .video(let videoMediaExtracted):
      if !showURLInstead {
        VideoPlayerPost(compact: compact, overrideWidth: contentWidth, sharedVideo: SharedVideo(url: videoMediaExtracted.url, size: CGSize(width: videoMediaExtracted.size.width, height: videoMediaExtracted.size.height)))
      }
    case .gallery(let imgs):
      if !showURLInstead {
        ImageMediaPost(compact: compact, post: post, images: imgs, contentWidth: contentWidth)
      }
    case .youtube(let videoID, let size):
      if !showURLInstead {
        PreviewYTLink(player: YouTubePlayer(source: .video(id: videoID)), videoID: videoID, size: size, contentWidth: contentWidth)
      }
    case .link(let url):
      if !showURLInstead {
        PreviewLink(url, compact: compact)
      } else {
        OnlyURL(url: url)
      }
    case .repost(let post):
      if !showURLInstead {
        if compact {
          if let postData = post.data, let url = URL(string: "https://reddit.com/r/\(postData.subreddit)/comments/\(post.id)") {
            PreviewLink(url, compact: compact)
          }
        } else {
          PostLinkNoSub(post: post, secondary: true)
        }
      } else if let postData = post.data, let url = URL(string: "https://reddit.com/r/\(postData.subreddit)/comments/\(post.id)") {
        OnlyURL(url: url)
      }
    case .post(let id, let subreddit):
      if !showURLInstead {
        if compact {
          if let url = URL(string: "https://reddit.com/r/\(subreddit)/comments/\(id)") {
            PreviewLink(url, compact: compact)
          }
        } else {
          PreviewRedditLinkContent(thing: .post(id: id, subreddit: subreddit))
        }
      } else if let url = URL(string: "https://reddit.com/r/\(subreddit)/comments/\(id)") {
        OnlyURL(url: url)
      }
    case .comment(let id, let postID, let subreddit):
      if !showURLInstead {
        if compact {
          if let url = URL(string: "https://reddit.com/r/\(subreddit)/comments/\(postID)/comment/\(id)") {
            PreviewLink(url, compact: compact)
          }
        } else {
          PreviewRedditLinkContent(thing: .comment(id: id, postID: postID, subreddit: subreddit))
        }
      } else if let url = URL(string: "https://reddit.com/r/\(subreddit)/comments/\(postID)/comment/\(id)") {
        OnlyURL(url: url)
      }
    case .subreddit(let name):
      if !showURLInstead {
        if compact {
          if let url = URL(string: "https://reddit.com/r/\(name)") {
            PreviewLink(url, compact: compact)
          }
        } else {
          PreviewRedditLinkContent(thing: .subreddit(name: name))
        }
      } else if let url = URL(string: "https://reddit.com/r/\(name)") {
        OnlyURL(url: url)
      }
    case .user(let username):
      if !showURLInstead {
        if compact {
          if let url = URL(string: "https://reddit.com/u/\(username)") {
            PreviewLink(url, compact: compact)
          }
        } else {
          PreviewRedditLinkContent(thing: .user(username: username))
        }
      } else if let url = URL(string: "https://reddit.com/u/\(username)") {
        OnlyURL(url: url)
      }
    }
  }
}
