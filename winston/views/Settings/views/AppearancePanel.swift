//
//  Appearance.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct AppearancePanel: View {
  @Default(.preferenceShowPostsAvatars) var preferenceShowPostsAvatars
  @Default(.preferenceShowCommentsAvatars) var preferenceShowCommentsAvatars
  @Default(.replyModalBlurBackground) var replyModalBlurBackground
  @Default(.newPostModalBlurBackground) var newPostModalBlurBackground
  @Default(.showUsernameInTabBar) var showUsernameInTabBar
  
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  
  @Default(.postLinksInnerHPadding) var postLinksInnerHPadding
  @Default(.postLinksInnerVPadding) var postLinksInnerVPadding
  
  @Default(.cardedPostLinksOuterHPadding) var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksOuterVPadding) var cardedPostLinksOuterVPadding
  @Default(.cardedPostLinksInnerHPadding) var cardedPostLinksInnerHPadding
  @Default(.cardedPostLinksInnerVPadding) var cardedPostLinksInnerVPadding
  
  @Default(.commentsInnerHPadding) var commentsInnerHPadding
  //  @Default(.commentsInnerVPadding) var commentsInnerVPadding
  
  @Default(.cardedCommentsOuterHPadding) var cardedCommentsOuterHPadding
  //  @Default(.cardedCommentsOuterVPadding) var cardedCommentsOuterVPadding
  @Default(.cardedCommentsInnerHPadding) var cardedCommentsInnerHPadding
  //  @Default(.cardedCommentsInnerVPadding) var cardedCommentsInnerVPadding
  
  @Default(.fadeReadPosts) var fadeReadPosts
  @Default(.coloredCommentNames) var coloredCommentNames
  @Default(.showUpvoteRatio) var showUpvoteRatio
  @Default(.compactMode) var compactMode
  
  @Default(.postLinkTitleSize) var postLinkTitleSize
  @Default(.postLinkBodySize) var postLinkBodySize
  @Default(.postViewTitleSize) var postViewTitleSize
  @Default(.postViewBodySize) var postViewBodySize
  @Default(.commentLinkBodySize) var commentLinkBodySize
  
  var body: some View {
    List {
      Section("General") {
        Toggle("Blur reply background", isOn: $replyModalBlurBackground)
        Toggle("Blur new post background", isOn: $newPostModalBlurBackground)
        Toggle("Show username in tab bar", isOn: $showUsernameInTabBar)
        
      }
      
      Section("Posts") {
        Picker("", selection: Binding(get: {
          preferenceShowPostsCards ? "Card" : "Flat"
        }, set: { val, _ in
          withAnimation(spring) {
            preferenceShowPostsCards = val == "Card"
          }
        })) {
          Text("Card").tag("Card")
          Text("Flat").tag("Flat")
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: .infinity)
        
        VStack(alignment: .leading) {
          Toggle("Fade read posts", isOn: $fadeReadPosts)
          Text("Uses fading instead of a glowing dot to tell read from unread posts.").fontSize(13).opacity(0.75)
        }
        Toggle("Compact mode", isOn: $compactMode)
        Toggle("Show avatars", isOn: $preferenceShowPostsAvatars)
        Toggle("Show upvote ratio", isOn: $showUpvoteRatio)
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post link title size")
            Spacer()
            Text("\(Int(postLinkTitleSize))")
              .opacity(0.6)
              .fontSize(postLinkTitleSize, .medium)
          }
          Slider(value: $postLinkTitleSize, in: 10...32, step: 1)
        }
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post link body size")
            Spacer()
            Text("\(Int(postLinkBodySize))")
              .opacity(0.6)
              .fontSize(postLinkBodySize)
          }
          Slider(value: $postLinkBodySize, in: 10...32, step: 1)
        }
        .disabled(compactMode)
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post page title size")
            Spacer()
            Text("\(Int(postViewTitleSize))")
              .opacity(0.6)
              .fontSize(postViewTitleSize, .semibold)
          }
          Slider(value: $postViewTitleSize, in: 10...32, step: 1)
        }
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post page body size")
            Spacer()
            Text("\(Int(postViewBodySize))")
              .opacity(0.6)
              .fontSize(postViewBodySize)
          }
          Slider(value: $postViewBodySize, in: 10...32, step: 1)
        }

        if preferenceShowPostsCards {
          VStack(alignment: .leading) {
            HStack {
              Text("Outer horizontal spacing")
              Spacer()
              Text("\(Int(cardedPostLinksOuterHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksOuterHPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Outer vertical spacing")
              Spacer()
              Text("\(Int(cardedPostLinksOuterVPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksOuterVPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Inner horizontal spacing")
              Spacer()
              Text("\(Int(cardedPostLinksInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksInnerHPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Inner vertical spacing")
              Spacer()
              Text("\(Int(cardedPostLinksInnerVPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksInnerVPadding, in: 0...32, step: 1)
          }
        } else {
          VStack(alignment: .leading) {
            HStack {
              Text("Horizontal spacing")
              Spacer()
              Text("\(Int(postLinksInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $postLinksInnerHPadding, in: 0...32, step: 1)
          }
          
          VStack(alignment: .leading) {
            HStack {
              Text("Vertical spacing")
              Spacer()
              Text("\(Int(postLinksInnerVPadding))")
                .opacity(0.6)
            }
            Slider(value: $postLinksInnerVPadding, in: 10...110, step: 1)
          }
        }
      }
      
      Section("Comments") {
        Picker("", selection: Binding(get: {
          preferenceShowCommentsCards ? "Card" : "Flat"
        }, set: { val, _ in
          withAnimation(spring) {
            preferenceShowCommentsCards = val == "Card"
          }
        })) {
          Text("Card").tag("Card")
          Text("Flat").tag("Flat")
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: .infinity)
        
        Toggle("Show avatars", isOn: $preferenceShowCommentsAvatars)
        Toggle("Colored usernames", isOn: $coloredCommentNames)
        
        
        VStack(alignment: .leading) {
          HStack {
            Text("Comment body size")
            Spacer()
            Text("\(Int(commentLinkBodySize))")
              .opacity(0.6)
              .fontSize(commentLinkBodySize)
          }
          Slider(value: $commentLinkBodySize, in: 10...32, step: 1)
        }
        
        if preferenceShowCommentsCards {
          VStack(alignment: .leading) {
            HStack {
              Text("Outer horizontal spacing")
              Spacer()
              Text("\(Int(cardedCommentsOuterHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedCommentsOuterHPadding, in: 0...32, step: 1)
          }
          //          VStack(alignment: .leading) {
          //            HStack {
          //              Text("Outer vertical spacing")
          //              Spacer()
          //              Text("\(Int(cardedCommentsOuterVPadding))")
          //                .opacity(0.6)
          //            }
          //            Slider(value: $cardedCommentsOuterVPadding, in: 0...32, step: 1)
          //          }
          VStack(alignment: .leading) {
            HStack {
              Text("Inner horizontal spacing")
              Spacer()
              Text("\(Int(cardedCommentsInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedCommentsInnerHPadding, in: 0...32, step: 1)
          }
          //          VStack(alignment: .leading) {
          //            HStack {
          //              Text("Inner vertical spacing")
          //              Spacer()
          //              Text("\(Int(cardedCommentsInnerVPadding))")
          //                .opacity(0.6)
          //            }
          //            Slider(value: $cardedCommentsInnerVPadding, in: 0...32, step: 1)
          //          }
        } else {
          VStack(alignment: .leading) {
            HStack {
              Text("Horizontal spacing")
              Spacer()
              Text("\(Int(commentsInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $commentsInnerHPadding, in: 0...32, step: 1)
          }
          
          //          VStack(alignment: .leading) {
          //            HStack {
          //              Text("Vertical spacing")
          //              Spacer()
          //              Text("\(Int(commentsInnerHPadding))")
          //                .opacity(0.6)
          //            }
          //            Slider(value: $commentsInnerVPadding, in: 10...110, step: 1)
          //          }
        }
      }
    }
    .navigationTitle("Appearance")
    .navigationBarTitleDisplayMode(.inline)
  }
}
//
//struct Appearance_Previews: PreviewProvider {
//    static var previews: some View {
//        Appearance()
//    }
//}
