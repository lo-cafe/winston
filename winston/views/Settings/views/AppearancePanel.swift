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
  @Default(.shinyTextAndButtons) var shinyTextAndButtons
  
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
  //  @Default(.preferInlineTags) var preferInlineTags
  @Default(.themeStoreTint) var themeStoreTint
  @Default(.showAuthorOnPostLinks) var showAuthorOnPostLinks
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  @EnvironmentObject private var routerProxy: RouterProxy
  @State private var appIconManager = AppIconManger()

  var body: some View {
    List {
      
      Section{
        WNavigationLink(value: theme){
          OnlineThemeItem(theme: ThemeData(theme_name: theme.metadata.name, theme_author:theme.metadata.author, theme_description: theme.metadata.description,color:theme.metadata.color, icon: theme.metadata.icon), showDownloadButton: false)
        }
        .navigationDestination(for: WinstonTheme.self) { theme in
          ThemeEditPanel(themeEditedInstance: ThemeEditedInstance(theme))
            .environmentObject(routerProxy)
        }
        .disabled(theme.id == "default")
      }  header: {
        Text("Current Theme")
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      
//      .background{
//        RadialGradient(gradient: Gradient(colors: [Color(uiColor: UIColor(hex: theme.metadata.color.hex)).opacity(0.3), theme.lists.foreground.color.cs(cs).color()]), center: UnitPoint(x: 0.25, y: 0.5), startRadius: 0, endRadius: UIScreen.main.bounds.width * 0.6)
//              .ignoresSafeArea(.all)
//      }
//      .listRowBackground(
//        RadialGradient(gradient: Gradient(colors: [Color(uiColor: UIColor(hex: theme.metadata.color.hex)).opacity(0.3), theme.lists.foreground.color.cs(cs).color()]), center: UnitPoint(x: 0.25, y: 0.5), startRadius: 0, endRadius: UIScreen.main.bounds.width * 0.6)
//              .ignoresSafeArea(.all)
//      )
//      .ifIOS17{ content in
//        if #available(iOS 17.0, *) {
//          content.listSectionSpacing(8)
//        }
//      }
      
      Section{
              WNavigationLink(value: SettingsPages.appIcon) {
                HStack{
                  Image(uiImage: appIconManager.current.preview)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .mask(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                  Text("App icon")
                }
              }
      }
      .ifIOS17{ content in
        if #available(iOS 17.0, *) {
          content.listSectionSpacing(15)
        }
      }
      
      Section {
        HStack(spacing: 12){
          ListBigBtn(value: SettingsPages.themes,icon: "paintbrush.fill", iconColor: Color.blue, label: "My Themes")
          ListBigBtn(value: SettingsPages.themeStore, icon: "basket.fill", iconColor: Color.orange, label: "Theme Store")
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
//      .padding(.vertical, -8)  Adjust the value as needed

     
      
      Section("General") {
        Group {
          Toggle("Show Username in Tab Bar", isOn: $showUsernameInTabBar)
          Toggle("Disable subs list letter sections", isOn: $disableAlphabetLettersSectionsInSubsList)
        }
        .themedListRowBG(enablePadding: true)
        .themedListDividers()
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
//        .themedListDividers()
//      }
      
      Section("Posts") {
        Group {
          Toggle("Show Upvote Ratio", isOn: $showUpvoteRatio)
          Toggle("Show Voting Buttons", isOn: $showVotes)
          Toggle("Show Self Text", isOn: $showSelfText)
          Toggle("Show Subreddit at Top", isOn: $showSubsAtTop)
          Toggle("Show Title at Top", isOn: $showTitleAtTop)
          Toggle("Show Author", isOn: $showAuthorOnPostLinks)
          //        Toggle("Prefer inline tags", isOn: $preferInlineTags)
        }
        .themedListRowBG(enablePadding: true)
        .themedListDividers()
      }
      
      Section("Compact Posts") {
        Group {
          Toggle("Compact Mode", isOn: $compactMode)
          Toggle("Show Thumbnail Placeholder", isOn: $showSelfPostThumbnails)
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
        .themedListDividers()
      }
      
      Section("Comments") {
        Toggle("Colored Usernames", isOn: $coloredCommentNames)
          .themedListRowBG(enablePadding: true)
          .themedListDividers()
      }
      
      Section("Accessibility"){
          Toggle("Theme Store Tint", isOn: $themeStoreTint)
        Toggle("\"Shiny\" Text and Buttons", isOn: $shinyTextAndButtons)
      }
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
      return 1.25
    }
  }
}

