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
  static let height: Double = 22
  @Default(.postLinkTitleSize) var postLinkTitleSize
  var url: URL
  @Environment(\.openURL) private var openURL
  var body: some View {
    HStack {
      Image(systemName: "link")
      Text(cleanURL(url: url, showPath: false))
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .frame(maxHeight: OnlyURL.height)
    .background(Capsule(style: .continuous).fill(Color.accentColor.opacity(0.2)))
    .fontSize(15, .medium)
    .lineLimit(1)
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
    lhs.media == rhs.media && lhs.contentWidth == rhs.contentWidth && lhs.compact == rhs.compact
  }
  
  var blurPostLinkNSFW: Bool
  var showURLInstead = false
  let media: MediaExtractedType
  var post: Post
  let compact: Bool
  let contentWidth: CGFloat
  let routerProxy: RouterProxy
  
  var body: some View {
    let over18 = post.data?.over_18 ?? false
    switch media {
    case .image(let imgMediaExtracted):
      if !showURLInstead {
        ImageMediaPost(compact: compact, post: post, images: [imgMediaExtracted], contentWidth: contentWidth)
          .nsfw(over18 && blurPostLinkNSFW)
      }
    case .video(let videoMediaExtracted):
      if !showURLInstead {
        VideoPlayerPost(post: post, compact: compact, overrideWidth: contentWidth, url: videoMediaExtracted.url, size: CGSize(width: videoMediaExtracted.size.width, height: videoMediaExtracted.size.height))
          .nsfw(over18 && blurPostLinkNSFW)
        
      }
    case .gallery(let imgs):
      if !showURLInstead {
        ImageMediaPost(compact: compact, post: post, images: imgs, contentWidth: contentWidth)
          .nsfw(over18 && blurPostLinkNSFW)
      }
    case .youtube(let videoID, let size):
      if !showURLInstead {
        YTMediaPost(compact: compact, videoID: videoID, size: size, contentWidth: contentWidth)
//          .equatable()
      }
    case .link(let url):
      if !showURLInstead {
        PreviewLink(url: url, compact: compact)
      } else {
        OnlyURL(url: url)
      }
    case .repost(let repost):
      if !showURLInstead {
        if compact {
          if let postData = repost.data, let url = URL(string: "https://reddit.com/r/\(postData.subreddit)/comments/\(repost.id)") {
            PreviewLink(url: url, compact: compact)
          }
        } else if let sub = repost.winstonData?.subreddit {
          PostLink(post: repost, sub: sub, showSub: true, secondary: true)
        }
      } else if let postData = repost.data, let url = URL(string: "https://reddit.com/r/\(postData.subreddit)/comments/\(repost.id)") {
        OnlyURL(url: url)
      }
    case .post(let id, let subreddit):
      if !showURLInstead {
        if compact {
          if let url = URL(string: "https://reddit.com/r/\(subreddit)/comments/\(id)") {
            PreviewLink(url: url, compact: compact)
          }
        } else {
          RedditMediaPost(thing: .post(id: id, subreddit: subreddit))
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
          RedditMediaPost(thing: .comment(id: id, postID: postID, subreddit: subreddit))
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
          RedditMediaPost(thing: .subreddit(name: name))
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
          RedditMediaPost(thing: .user(username: username))
        }
      } else if let url = URL(string: "https://reddit.com/u/\(username)") {
        OnlyURL(url: url)
      }
    }
  }
}
