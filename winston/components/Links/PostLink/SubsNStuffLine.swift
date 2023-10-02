//
//  SubsNStuffLine.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct SubsNStuffLine: View, Equatable {
  static let height = FlairTag.height + 4
  static func == (lhs: SubsNStuffLine, rhs: SubsNStuffLine) -> Bool {
    lhs.post.id == rhs.post.id
  }
  
  var showSub: Bool
  var feedsAndSuch: [String]
  @ObservedObject var post: Post
  @ObservedObject var sub: Subreddit
  var routerProxy: RouterProxy
  var over18: Bool
  
  var body: some View {
//    if (showSub || feedsAndSuch.contains(sub.id)) || over18 || post.data?.link_flair_text != nil {
      HStack(spacing: 0) {
        
        if showSub || feedsAndSuch.contains(sub.id) {
//          if !over18 && post.data?.link_flair_text == nil {
//            WDivider()
//          }
          FlairTag(data: sub.data, text: "r/\(sub.data?.display_name ?? post.data?.subreddit ?? "Error")", color: .blue)
            .highPriorityGesture(TapGesture() .onEnded {
              routerProxy.router.path.append(SubViewType.posts(Subreddit(id: post.data?.subreddit ?? "", api: post.redditAPI)))
            })
          WDivider()
        }
        
        if over18 {
          FlairTag(text: "NSFW", color: .red)
        }
        
        if let link_flair_text = post.data?.link_flair_text {
          WDivider()
          FlairTag(text: link_flair_text)
            .allowsHitTesting(false)
        }
        
        if !showSub && !feedsAndSuch.contains(sub.id) && !over18 {
          WDivider()
        }
      }
      .padding(.horizontal, 2)
      .frame(height: SubsNStuffLine.height)
//    }
  }
}
