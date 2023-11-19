//
//  SubsNStuffLine.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct SubsNStuffLine: View, Equatable {
  static func == (lhs: SubsNStuffLine, rhs: SubsNStuffLine) -> Bool {
    true
  }
  
//  static let height = Tag.height + 4
  static let height: CGFloat = 1
  
  var showSub: Bool?
  var feedsAndSuch: [String]?
  var subredditIconKit: SubredditIconKit?
  var sub: Subreddit?
  var flair: String?
  var routerProxy: RouterProxy?
  var over18: Bool?
  
  var body: some View {
//    let subName = sub.data?.name ?? ""
    //    if (showSub || feedsAndSuch.contains(sub.id)) || over18 || post.data?.link_flair_text != nil {
    HStack(spacing: 0) {
      WDivider()
//      if showSub || feedsAndSuch.contains(sub.id) {
//        Tag(subredditIconKit: subredditIconKit, text: "r/\(subName)", color: .blue)
//          .highPriorityGesture(TapGesture() .onEnded {
//            routerProxy.router.path.append(SubViewType.posts(Subreddit(id: subName, api: RedditAPI.shared)))
//          })
//        if over18 {
//          WDivider()
//        }
//      }
//      
//      if over18 {
//        Tag(text: "NSFW", color: .red)
//      }
//      
//      WDivider()
//      
//      if let flair = flair {
//        Tag(text: flair)
//          .allowsHitTesting(false)
//      }
    }
    .padding(.horizontal, 2)
    .frame(height: SubsNStuffLine.height)
    //    }
  }
}
