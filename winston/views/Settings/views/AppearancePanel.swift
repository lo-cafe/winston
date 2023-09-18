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
  @Default(.showSubsAtTop) var showSubsAtTop
  @Default(.showTitleAtTop) var showTitleAtTop
  //Compact Mode
  @Default(.compactMode) var compactMode
  @Default(.showVotes) var showVotes
  @Default(.showSelfText) var showSelfText
  @Default(.compThumbnailSize) var compThumbnailSize
  @Default(.thumbnailPositionRight) var thumbnailPositionRight
  @Default(.voteButtonPositionRight) var voteButtonPositionRight
  @Default(.showSelfPostThumbnails) var showSelfPostThumbnails
  @Default(.disableAlphabetLettersSectionsInSubsList) var disableAlphabetLettersSectionsInSubsList
  
  @Default(.commentLinkBodySize) var commentLinkBodySize

  var body: some View {
    List {
      Section("General") {
        Toggle("Blur Reply Background", isOn: $replyModalBlurBackground)
        Toggle("Blur New Post Background", isOn: $newPostModalBlurBackground)
        Toggle("Show Username in Tab Bar", isOn: $showUsernameInTabBar)
        Toggle("Disable subs list letter sections", isOn: $disableAlphabetLettersSectionsInSubsList)
      }
      
      Section {
        NavigationLink(value: SettingsPages.themes) {
          Label("Themes", systemImage: "paintbrush.fill")
        }
      } footer: {
        Text("This is a special menu because in Winston you can change 90% of what you see. Enjoy the theming system!")
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
        Toggle("Show Avatars", isOn: $preferenceShowPostsAvatars)
        Toggle("Show Upvote Ratio", isOn: $showUpvoteRatio)
        Toggle("Show Voting Buttons", isOn: $showVotes)
        Toggle("Show Self Text", isOn: $showSelfText)
        Toggle("Show Subreddit at Top", isOn: $showSubsAtTop)
        Toggle("Show Title at Top", isOn: $showTitleAtTop)
        
        NavigationLink(value: SettingsPages.postFontSettings){
          Label("Text Size", systemImage: "text.magnifyingglass")
            .labelStyle(.titleOnly)
        }

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
        Toggle("Compact Mode", isOn: $compactMode)
        Toggle("Show Self Post Thumbnails", isOn: $showSelfPostThumbnails)
        Picker("Thumbnail Position", selection: Binding(get: {
          thumbnailPositionRight ? "Right" : "Left"
        }, set: {val, _ in
          thumbnailPositionRight = val == "Right"
        })){
          Text("Left").tag("Left")
          Text("Right").tag("Right")
        }
        
        Picker("Thumbnail Size", selection: Binding(get: {
          compThumbnailSize
        }, set: { val, _ in
          compThumbnailSize = val
          // This is a bit of a hacky way of refreshing the images, but it works
          compactMode = false
          compactMode = true
        })){
          Text("Hidden").tag(ThumbnailSizeModifier.hidden)
          Text("Small").tag(ThumbnailSizeModifier.small)
          Text("Medium").tag(ThumbnailSizeModifier.medium)
          Text("Large").tag(ThumbnailSizeModifier.large)
        }
        
        Picker("Voting Buttons Position", selection: Binding(get: {
          voteButtonPositionRight ? "Right" : "Left"
        }, set: {val, _ in
          voteButtonPositionRight = val == "Right"
        })){
          Text("Left").tag("Left")
          Text("Right").tag("Right")
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
        
        Toggle("Show Avatars", isOn: $preferenceShowCommentsAvatars)
        Toggle("Colored Usernames", isOn: $coloredCommentNames)
        
        VStack(alignment: .leading) {
          HStack {
            Text("Comment Body Size")
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
//      .alert(isPresented: $compThumbnailSize){
//        Alert(title: "Please refresh your Home Feed.")
//      }
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


//Compact Mode Thumbnail Size Modifiers
enum ThumbnailSizeModifier:  Codable, CaseIterable, Identifiable, Defaults.Serializable{
  var id: CGFloat {
    self.rawVal
  }
  
  case hidden
  case small
  case medium
  case large
  
  var rawVal: CGFloat {
    switch self{
    case .hidden:
      return 0.0
    case .small:
      return 0.75
    case .medium:
      return 1.0
    case .large:
      return 1.5
    }
  }
}

