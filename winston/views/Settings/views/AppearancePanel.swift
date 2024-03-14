//
//  Appearance.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct AppearancePanel: View {
  @Default(.PostLinkDefSettings) var postLinkDefSettings
  @Default(.AppearanceDefSettings) var appearanceDefSettings
  @Default(.CommentLinkDefSettings) var commentLinkDefSettings
  @Default(.SubredditFeedDefSettings) var subFeedDefSettings
  
  @Environment(\.useTheme) private var theme
  @State private var appIconManager = AppIconManger()
  
  var body: some View {
    List {
      // MARK: -- THEME
      Group {
        //        Section {
        //          WListButton(showArrow: true) {
        //            Nav.present(.editingTheme(theme))
        //          } label: {
        //            OnlineThemeItem(theme: ThemeData(theme_name: theme.metadata.name, theme_author:theme.metadata.author, theme_description: theme.metadata.description,color:theme.metadata.color, icon: theme.metadata.icon), showDownloadButton: false)
        //          }
        //          .disabled(theme.id == "default")
        //        } header: {
        //          Text("Current Theme")
        //        }
        //        .listRowSeparator(.hidden)
        
        Section {
          WNavigationLink(value: .setting(.appIcon)) {
            HStack{
              Image(uiImage: appIconManager.current.preview)
                .resizable()
                .frame(width: 32, height: 32)
                .mask(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
              Text("App icon")
            }
          }
        }
        .listSectionSpacing(15)
        
        Section {
          HStack(spacing: 12){
            ListBigBtn(icon: "paintbrush.fill", iconColor: Color.blue, label: "My Themes") { Nav.to(.setting(.themes)) }
            ListBigBtn(icon: "basket.fill", iconColor: Color.orange, label: "Theme Store") { Nav.to(.setting(.themeStore)) }
          }
        } footer: {
          if theme.id == "default" {
            Text("Please go into \"My Theme\" and create a new one if you want to edit it")
              .padding(.top)
          }
        }
        .frame(maxWidth: .infinity)
        .id("bigButtons")
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        // MARK: -- General
        Section("General") {
          Toggle("Show Username in Tab Bar", isOn: $appearanceDefSettings.showUsernameInTabBar)
          Toggle("Disable Subs List Letter Sections", isOn: $appearanceDefSettings.disableAlphabetLettersSectionsInSubsList)
          Toggle("Show Prefix on Feed Title", isOn: $subFeedDefSettings.showPrefixOnFeedTitle)
        }
        
        //      Section("Theming") {
        //        Group {
        //          WNavigationLink(value: SettingsPages.themes) {
        //            Label("Themes", systemImage: "paintbrush.fill")
        //          }
        //          WNavigationLink(value: SettingsPages.appIcon) {
        //            Label("App icon", systemImage: "appclip")
        //          }
        //          WNavigationLink(value: SettingsPages.themeStore){
        //            Label("Theme Store (alpha)", systemImage: "giftcard.fill")
        //          }
        //        }
        //        .themedListSection()
        //      }
        //
        // MARK: -- Posts
        Section("Posts") {
          Toggle("Show Upvote Ratio", isOn: $postLinkDefSettings.showUpVoteRatio)
          Toggle("Show Voting Buttons", isOn: $postLinkDefSettings.showVotesCluster)
          Toggle("Show Self Text", isOn: $postLinkDefSettings.showSelfText)
          Toggle("Show Divider at Top", isOn: Binding(get: {
            postLinkDefSettings.dividerPosition == .top
          }, set: { postLinkDefSettings.dividerPosition = $0 ? .top : .bottom } ))
          Toggle("Show Title at Top", isOn: Binding(
            get: { postLinkDefSettings.titlePosition == .top },
            set: { postLinkDefSettings.titlePosition = $0 ? .top : .bottom } )
          )
          Toggle("Show Author", isOn: $postLinkDefSettings.showAuthor)
        }
        // MARK: -- Compact Posts
        Section("Compact Posts") {
          Toggle("Compact Mode", isOn: $postLinkDefSettings.compactMode.enabled)
          
          if postLinkDefSettings.compactMode.enabled {
            Toggle("Show Thumbnail Placeholder", isOn: $postLinkDefSettings.compactMode.showPlaceholderThumbnail)
            Picker("Thumbnail Position", selection: Binding(
              get: { postLinkDefSettings.compactMode.thumbnailSide == .trailing ? "Right" : "Left" },
              set: { postLinkDefSettings.compactMode.thumbnailSide = $0 == "Right" ? .trailing : .leading })
            ){
              Text("Left").tag("Left")
              Text("Right").tag("Right")
            }
            
            Picker("Thumbnail Size", selection: Binding(get: {
              postLinkDefSettings.compactMode.thumbnailSize
            }, set: { val, _ in
              postLinkDefSettings.compactMode.thumbnailSize = val
            })) {
              Text("Hidden").tag(ThumbnailSizeModifier.hidden)
              Text("Small").tag(ThumbnailSizeModifier.small)
              Text("Medium").tag(ThumbnailSizeModifier.medium)
              Text("Large").tag(ThumbnailSizeModifier.large)
            }
            
            Picker("Voting Buttons Position", selection: Binding(get: {
              postLinkDefSettings.compactMode.voteButtonsSide == .trailing ? "Right" : "Left"
            }, set: {val, _ in
              postLinkDefSettings.compactMode.voteButtonsSide = val == "Right" ? .trailing : .leading
            })){
              Text("Left").tag("Left")
              Text("Right").tag("Right")
            }
          }
        }
        
        // MARK: -- Comments
        Section("Comments") {
          Toggle("Colored Usernames", isOn: $commentLinkDefSettings.coloredNames)
          Picker("Next Comment Button Position", selection: Binding(get: {
            commentLinkDefSettings.jumpNextCommentButtonLeft ? "Left" : "Right"
          }, set: { val, _ in
            commentLinkDefSettings.jumpNextCommentButtonLeft = val == "Left" ? true : false
          })) {
            Text("Left").tag("Left")
            Text("Right").tag("Right")
          }
        }
        // MARK: -- Accessibility
        Section("Accessibility"){
          Toggle("Theme Store Tint", isOn: $appearanceDefSettings.themeStoreTint)
          Toggle("\"Shiny\" Text and Buttons", isOn: $appearanceDefSettings.shinyTextAndButtons)
        }
        
      }
      .themedListSection()
    }
    .animation(.spring, value: postLinkDefSettings.compactMode.enabled)
    .themedListBG(theme.lists.bg)
    .navigationTitle("Appearance")
    .navigationBarTitleDisplayMode(.inline)
  }
}



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
      return 1.25
    }
  }
}

