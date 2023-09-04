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

struct MediaPresenter: View, Equatable {
  static func == (lhs: MediaPresenter, rhs: MediaPresenter) -> Bool {
    lhs.media == rhs.media
  }
  
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
        VideoPlayerPost(post: post, compact: compact, overrideWidth: contentWidth, url: videoMediaExtracted.url, size: CGSize(width: videoMediaExtracted.size.width, height: videoMediaExtracted.size.height))
      }
    case .gallery(let imgs):
      if !showURLInstead {
        ImageMediaPost(compact: compact, post: post, images: imgs, contentWidth: contentWidth)
      }
    case .youtube(let videoID, let size):
      if !showURLInstead {
        PreviewYTLink(videoID: videoID, size: size, contentWidth: contentWidth)
          .equatable()
      }
    case .link(let url):
      if !showURLInstead {
        PreviewLink(url: url, compact: compact)
      } else {
        OnlyURL(url: url)
      }
    case .repost(let post):
      if !showURLInstead {
        if compact {
          if let postData = post.data, let url = URL(string: "https://reddit.com/r/\(postData.subreddit)/comments/\(post.id)") {
            PreviewLink(url: url, compact: compact)
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
            PreviewLink(url: url, compact: compact)
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
            PreviewLink(url: url, compact: compact)
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
            PreviewLink(url: url, compact: compact)
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
            PreviewLink(url: url, compact: compact)
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

extension MediaExtractedType: Equatable {
    static func ==(lhs: MediaExtractedType, rhs: MediaExtractedType) -> Bool {
        switch (lhs, rhs) {
        case let (.image(a), .image(b)):
            return a == b
        case let (.video(a), .video(b)):
            return a == b
        case let (.gallery(a), .gallery(b)):
            return a == b
        case let (.youtube(videoID: a, size: b), .youtube(videoID: c, size: d)):
            return a == c && b == d
        case let (.link(a), .link(b)):
            return a == b
        case let (.repost(a), .repost(b)):
            return a == b
        case let (.post(id: a, subreddit: b), .post(id: c, subreddit: d)):
            return a == c && b == d
        case let (.comment(id: a, postID: b, subreddit: c), .comment(id: d, postID: e, subreddit: f)):
            return a == d && b == e && c == f
        case let (.subreddit(a), .subreddit(b)):
            return a == b
        case let (.user(a), .user(b)):
            return a == b
        default:
            return false
        }
    }
}
