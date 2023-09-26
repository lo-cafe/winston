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
  @Default(.showUsernameInTabBar) var showUsernameInTabBar
  
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
  
  @Environment(\.useTheme) private var theme
  
  var body: some View {
    List {
      Section("General") {
        Group {
          Toggle("Show Username in Tab Bar", isOn: $showUsernameInTabBar)
          Toggle("Disable subs list letter sections", isOn: $disableAlphabetLettersSectionsInSubsList)
        }
        .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      
      Section {
        WNavigationLink(value: SettingsPages.themes) {
          Label("Themes", systemImage: "paintbrush.fill")
        }
        WNavigationLink(value: SettingsPages.themeStore){
          Label("Theme Store (alpha)", systemImage: "giftcard.fill")
        }
      } footer: {
        Text("This is a special menu because in Winston you can change 90% of what you see. Enjoy the theming system!")
      }
      
      Section("Posts") {
        Group {
        Toggle("Show Upvote Ratio", isOn: $showUpvoteRatio)
        Toggle("Show Voting Buttons", isOn: $showVotes)
        Toggle("Show Self Text", isOn: $showSelfText)
        Toggle("Show Subreddit at Top", isOn: $showSubsAtTop)
        Toggle("Show Title at Top", isOn: $showTitleAtTop)
        }
        .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      
      Section("Compact Posts"){
        Group {
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
        .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      
      Section("Comments") {
        Toggle("Colored Usernames", isOn: $coloredCommentNames)
          .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      //      .alert(isPresented: $compThumbnailSize){
      //        Alert(title: "Please refresh your Home Feed.")
      //      }
    }
    .themedListBG(theme.lists.bg)
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

