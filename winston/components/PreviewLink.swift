//
//  File.swift
//  winston
//
//  Created by Igor Marcossi on 28/07/23.
//

import Foundation
import SwiftUI
import Kingfisher
import OpenGraph
import SkeletonUI

class PreviewLinkCache {
  static var shared = PreviewLinkCache()
  var cache: [String:PreviewViewModel] = [:]
}

final class PreviewViewModel: ObservableObject {
  
  @Published var image: String?
  @Published var title: String?
  @Published var url: String?
  @Published var description: String?
  @Published var loading = true
  
  let previewURL: URL?
  
  init(_ url: String) {
    self.previewURL = URL(string: url)
    
    fetchMetadata()
  }
  
  private func fetchMetadata() {
    guard let previewURL else { return }
    Task {
      if let og = try? await OpenGraph.fetch(url: previewURL) {
        
        
        await MainActor.run {
          withAnimation {
            image = og[.image]
            title = og[.title]
            description = og[.description]
            url = og[.url]
            loading = false
          }
        }
      }
    }
  }
}

struct PreviewLink: View {
  var url: String
  var redditURL: RedditURLType?
  
  init(_ url: String) {
    self.url = url
//    print(url)
    if let redditLink = parseRedditURL(url) {
//      print(redditLink.self)
      self.redditURL = redditLink
    } else {
      if PreviewLinkCache.shared.cache[url] == nil {
        PreviewLinkCache.shared.cache[self.url] = PreviewViewModel(self.url)
      }
    }
  }
  
  var body: some View {
    if let redditURL = redditURL {
      PreviewRedditLinkContent(thing: redditURL)
    } else {
      PreviewLinkContent(viewModel: PreviewLinkCache.shared.cache[url]!, url: URL(string: url)!)
    }
  }
}

struct PreviewLinkContent: View {
  @StateObject var viewModel: PreviewViewModel
  var url: URL
  private let height: CGFloat = 88
  @Environment(\.openURL) var openURL
  
  var body: some View {
    HStack(spacing: 16) {
      
      VStack(alignment: .leading, spacing: 2) {
        VStack(alignment: .leading, spacing: 0) {
          Text(viewModel.title ?? "")
            .fontSize(17, .medium)
          
          Text(viewModel.url ?? "")
            .fontSize(13)
            .opacity(0.5)
        }
        
        Text(viewModel.description)
          .fontSize(14)
          .lineLimit(2)
          .opacity(0.75)
          .fixedSize(horizontal: false, vertical: true)
      }
      .skeleton(with: viewModel.title.isNil)
      .multiline(lines: 4, scales: [1: 1, 2: 0.5, 3: 0.75, 4: 0.75])
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.leading)
      
      if let image = viewModel.image {
        KFImage(URL(string: image)!)
          .resizable()
          .fade(duration: 0.5)
          .scaledToFill()
          .frame(width: 76, height: 76)
          .clipped()
          .mask(RR(12, .black))
      } else {
        ProgressView()
          .frame(width: 76, height: 76)
          .background(RR(12, .primary.opacity(0.05)))
      }
    }
    .padding(.vertical, 6)
    .padding(.leading, 10)
    .padding(.trailing, 6)
    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    .background(RR(16, .primary.opacity(0.05)))
    .highPriorityGesture(TapGesture().onEnded { openURL(url) })
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
    //    .padding(.vertical, 6)
    //    .padding(.leading, 10)
    //    .padding(.trailing, 6)
    //    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    //    .background(RR(16, .primary.opacity(0.05)))
    //    .highPriorityGesture(TapGesture().onEnded { openURL(url) })
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
      case .other:
        break
      }
    }
  }
}
