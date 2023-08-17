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
  @Default(.showVotes) var showVotes
  @Default(.showSelfText) var showSelfText
  
  var body: some View {
    List {
      Section("General") {
        Toggle("Blur Reply Background", isOn: $replyModalBlurBackground)
        Toggle("Blur New Post Background", isOn: $newPostModalBlurBackground)
        Toggle("Show Username in Tab Bar", isOn: $showUsernameInTabBar)
        
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
          Toggle("Fade Read Posts", isOn: $fadeReadPosts)
          Text("Uses fading instead of a glowing dot to tell read from unread posts.").fontSize(13).opacity(0.75)
        }
        Toggle("Show avatars", isOn: $preferenceShowPostsAvatars)
        Toggle("Show upvote ratio", isOn: $showUpvoteRatio)
        Toggle("Show Voting Buttons", isOn: $showVotes)
        Toggle("Show Self Text", isOn: $showSelfText)
        if preferenceShowPostsCards {
          VStack(alignment: .leading) {
            HStack {
              Text("Outer Horizontal Spacing")
              Spacer()
              Text("\(Int(cardedPostLinksOuterHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksOuterHPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Outer Vertical Spacing")
              Spacer()
              Text("\(Int(cardedPostLinksOuterVPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksOuterVPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Inner Horizontal Spacing")
              Spacer()
              Text("\(Int(cardedPostLinksInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksInnerHPadding, in: 0...32, step: 1)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("Inner Vertical Spacing")
              Spacer()
              Text("\(Int(cardedPostLinksInnerVPadding))")
                .opacity(0.6)
            }
            Slider(value: $cardedPostLinksInnerVPadding, in: 0...32, step: 1)
          }
        } else {
          VStack(alignment: .leading) {
            HStack {
              Text("Horizontal Spacing")
              Spacer()
              Text("\(Int(postLinksInnerHPadding))")
                .opacity(0.6)
            }
            Slider(value: $postLinksInnerHPadding, in: 0...32, step: 1)
          }
          
          VStack(alignment: .leading) {
            HStack {
              Text("Vertical Spacing")
              Spacer()
              Text("\(Int(postLinksInnerVPadding))")
                .opacity(0.6)
            }
            Slider(value: $postLinksInnerVPadding, in: 10...110, step: 1)
          }
        }
      }
      
      Section("Compact Posts"){
        Toggle("Compact mode", isOn: $compactMode)
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
        
        Toggle("Show Avatars", isOn: $preferenceShowCommentsAvatars)
        Toggle("Colored Usernames", isOn: $coloredCommentNames)
        if preferenceShowCommentsCards {
          VStack(alignment: .leading) {
            HStack {
              Text("Outer Horizontal Spacing")
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
              Text("Inner Horizontal Spacing")
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
              Text("Horizontal Spacing")
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
