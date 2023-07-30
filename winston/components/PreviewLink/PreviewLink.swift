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
  var redditURL: RedditURLType
  var media: Either<SecureMediaRedditVideo, SecureMediaAlt>?
  var contentWidth: CGFloat
  
  init(_ url: String, contentWidth: CGFloat, media: Either<SecureMediaRedditVideo, SecureMediaAlt>?) {
    self.url = url
    self.media = media
    self.contentWidth = contentWidth
    self.redditURL = parseRedditURL(url)
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



private enum ThingType {
  case post(Post)
  case comment(Comment)
  case user(User)
  case subreddit(Subreddit)
}

struct PreviewRedditLinkContent: View {
  var thing: RedditURLType
  @State private var thingEntity: ThingType?
  private let height: CGFloat = 88
  @EnvironmentObject var redditAPI: RedditAPI
  
  var body: some View {
    HStack(spacing: 16) {
      if let entity = thingEntity {
        switch entity {
        case .comment(let comment):
          VStack {
            //            ShortCommentPostLink(comment: comment)
            CommentLink(showReplies: false, comment: comment)
          }
          .padding(.vertical, 8)
        case .post(let post):
          ShortPostLink(reset: false, noHPad: true, post: post)
        case .user(let user):
          UserLinkContainer(reset: false, noHPad: true, user: user)
        case .subreddit(let subreddit):
          SubredditLinkContainer(reset: false, sub: subreddit)
        }
      } else {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88)
      }
    }
    .padding(.horizontal, 8)
    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.primary.opacity(0.05)))
    .onAppear {
      switch thing {
      case .comment(let id, _, _):
        Task {
          if let data = await redditAPI.fetchInfo(fullnames: ["\(Comment.prefix)_\(id)"]) {
            await MainActor.run { withAnimation {
              switch data {
              case .comment(let listing):
                if let data = listing.data?.children?[0].data {
                  thingEntity = .comment(Comment(data: data, api: redditAPI))
                }
              default:
                break
              }
            } }
          }
        }
      case .post(let id, _):
        Task {
          //          print("maos", id)
          if let data = await redditAPI.fetchInfo(fullnames: ["\(Post.prefix)_\(id)"]) {
            await MainActor.run { withAnimation {
              switch data {
              case .post(let listing):
                if let data = listing.data?.children?[0].data {
                  thingEntity = .post(Post(data: data, api: redditAPI))
                }
              default:
                break
              }
            } }
          }
        }
      case .user(let username):
        Task {
          if let data = await redditAPI.fetchUser(username) {
            await MainActor.run { withAnimation {
              thingEntity = .user(User(data: data, api: redditAPI))
            } }
          }
        }
      case .subreddit(name: let name):
        Task {
          if let data = (await redditAPI.fetchSub(name))?.data  {
            await MainActor.run { withAnimation {
              thingEntity = .subreddit(Subreddit(data: data, api: redditAPI))
            } }
          }
        }
      default:
        break
      }
    }
  }
}
