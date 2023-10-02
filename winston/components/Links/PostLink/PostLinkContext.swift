//
//  PostLinkContext.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct PostLinkContextPreview: View {
  var post: Post
  var sub: Subreddit
  var routerProxy: RouterProxy
  var body: some View {
    NavigationStack { PostView(post: post, subreddit: sub, forceCollapse: true).environmentObject(routerProxy) }
  }
}

struct PostLinkContext: View {
  @ObservedObject var post: Post
  var body: some View {
    //        if let perma = post.winstonData?.permaURL {
    //          ShareLink(item: perma) { Label("Share", systemImage: "square.and.arrow.up") }
    //        }
    ForEach(allPostSwipeActions) { action in
      let active = action.active(post)
      if action.enabled(post) {
        Button {
          Task(priority: .background) {
            await action.action(post)
          }
        } label: {
          Label(active ? "Undo \(action.label.lowercased())" : action.label, systemImage: active ? action.icon.active : action.icon.normal)
            .foregroundColor(action.bgColor.normal == "353439" ? action.color.normal == "FFFFFF" ? Color.accentColor : Color.hex(action.color.normal) : Color.hex(action.bgColor.normal))
        }
      }
    }
  }
}
