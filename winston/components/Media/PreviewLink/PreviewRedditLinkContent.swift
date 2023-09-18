//
//  PreviewRedditLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI
import Combine

enum ThingType {
  case post(Post)
  case comment(Comment)
  case user(User)
  case subreddit(Subreddit)
}

class ThingEntityCache: ObservableObject {
  static var shared = ThingEntityCache()
  @Published var thingEntities: [RedditURLType:ThingType] = [:]
  
  func load(_ thing: RedditURLType, redditAPI: RedditAPI) {
    if !thingEntities[thing].isNil { return }
    Task(priority: .background) {
      switch thing {
      case .comment(let id, _, _):
        if let data = await redditAPI.fetchInfo(fullnames: ["\(Comment.prefix)_\(id)"]) {
          await MainActor.run { withAnimation {
            switch data {
            case .comment(let listing):
              if let data = listing.data?.children?[0].data {
                thingEntities[thing] = .comment(Comment(data: data, api: redditAPI))
              }
            default:
              break
            }
          } }
        }
      case .post(let id, _):
        //          print("maos", id)
        if let data = await redditAPI.fetchInfo(fullnames: ["\(Post.prefix)_\(id)"]) {
          await MainActor.run { withAnimation {
            switch data {
            case .post(let listing):
              if let data = listing.data?.children?[0].data {
                thingEntities[thing] = .post(Post(data: data, api: redditAPI))
              }
            default:
              break
            }
          } }
        }
      case .user(let username):
        if let data = await redditAPI.fetchUser(username) {
          await MainActor.run { withAnimation {
            thingEntities[thing] = .user(User(data: data, api: redditAPI))
          } }
        }
      case .subreddit(name: let name):
        Task(priority: .background) {
          if let data = (await redditAPI.fetchSub(name))?.data  {
            await MainActor.run { withAnimation {
              thingEntities[thing] = .subreddit(Subreddit(data: data, api: redditAPI))
            } }
          }
        }
      default:
        break
      }
    }
  }
  
  private let _objectWillChange = PassthroughSubject<Void, Never>()
  
  var objectWillChange: AnyPublisher<Void, Never> { _objectWillChange.eraseToAnyPublisher() }
  
  subscript(key: RedditURLType) -> ThingType? {
    get { thingEntities[key] }
    set {
      thingEntities[key] = newValue
      _objectWillChange.send()
    }
  }
  
  func merge(_ dict: [RedditURLType:ThingType]) {
    thingEntities.merge(dict) { (_, new) in new }
    _objectWillChange.send()
  }
}

struct PreviewRedditLinkContent: View {
  var thing: RedditURLType
  @ObservedObject private var thingEntitiesCache = ThingEntityCache.shared
  private let height: CGFloat = 88
  @EnvironmentObject private var redditAPI: RedditAPI
  
  var body: some View {
    HStack(spacing: 16) {
      if let entity = thingEntitiesCache[thing] {
        switch entity {
        case .comment(let comment):
          VStack {
            //            ShortCommentPostLink(comment: comment)
            CommentLink(showReplies: false, comment: comment)
//              .equatable()
          }
          .padding(.vertical, 8)
        case .post(let post):
          ShortPostLink(noHPad: true, post: post)
        case .user(let user):
          UserLinkContainer(noHPad: true, user: user)
        case .subreddit(let subreddit):
          SubredditLinkContainer(sub: subreddit)
        }
      } else {
        ProgressView()
          .onAppear {
            thingEntitiesCache.load(thing, redditAPI: redditAPI)
          }
      }
    }
    .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88)
    .padding(.horizontal, 8)
    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.primary.opacity(0.05)))

  }
}
