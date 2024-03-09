//
//  Behavior.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults
import VisionKit

struct BehaviorPanel: View {
  @Default(.BehaviorDefSettings) var behaviorDefSettings
  @Default(.PostLinkDefSettings) var postLinkDefSettings
  @Default(.PostPageDefSettings) var postPageDefSettings
  @Default(.CommentLinkDefSettings) var commentLinkDefSettings
  @Default(.CommentsSectionDefSettings) var commentsSectionDefSettings
  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
  @Default(.GeneralDefSettings) var generalDefSettings
  @Default(.VideoDefSettings) var videoDefSettings
  
  @Environment(\.useTheme) private var theme
  @State private var imageAnalyzerSupport: Bool = true
  var body: some View {
    List {
      
      Group {
        Section("General") {
          Toggle("Open Youtube Videos Externally", isOn: $behaviorDefSettings.openYoutubeApp)
#if !os(macOS)
          let auth_type = Biometrics().biometricType()
          Toggle("Lock Winston With \(auth_type)", isOn: $generalDefSettings.useAuth)
#endif
          
          VStack{
            Toggle("Live Text Analyzer", isOn: $behaviorDefSettings.doLiveText)
              .disabled(!imageAnalyzerSupport)
              .onAppear{
                imageAnalyzerSupport = ImageAnalyzer.isSupported
                if !ImageAnalyzer.isSupported {
                  behaviorDefSettings.doLiveText = false
                }
              }
            
            
            if !imageAnalyzerSupport{
              HStack{
                Text("Your iPhone does not support Live Text :(")
                  .fontSize(12)
                  .opacity(0.5)
                Spacer()
              }
            }
          }
          
          Picker("Default Launch Feed", selection: $behaviorDefSettings.preferenceDefaultFeed) {
            Text("Home").tag("home")
            Text("Popular").tag("popular")
            Text("All").tag("all")
            Text("Subscription List").tag("subList")
          }
          .pickerStyle(DefaultPickerStyle())
          
          WSNavigationLink(.setting(.filteredSubreddits), "Filtered Subreddits")
        }
        
        
        Section {
          LabeledSlider(label: "Loading limit", value: Binding(get: { CGFloat(subredditFeedDefSettings.chunkLoadSize) }, set: { val in subredditFeedDefSettings.chunkLoadSize = Int(val) }), range: 15...100, disablePadding: true)
          //            .themedListRowLikeBG(enablePadding: true, disableBG: true)
        } footer: {
          Text("Sets how many posts to load per chunk (loads more on scroll)")
        }
        
        Section {
          Toggle("Navigation everywhere", isOn: $behaviorDefSettings.enableSwipeAnywhere)
        } footer: {
          Text("This will allow you to do go back by swiping anywhere in the screen, but will disable post and comments swipe gestures.")
            .padding(.bottom)
        }
        
        Section("Posts") {
          WSNavigationLink(.setting(.postSwipe), "Posts swipe settings")
          Toggle("Loop videos", isOn: $videoDefSettings.loop)
          Toggle("Autoplay videos (muted)", isOn: $videoDefSettings.autoPlay)
          Toggle("Default mute fullscreen videos", isOn: $videoDefSettings.mute)
          Toggle("Pause background audio on fullscreen", isOn: $videoDefSettings.pauseBGAudioOnFullscreen)
          Toggle("Read on preview media", isOn: $postLinkDefSettings.lightboxReadsPost)
          Toggle("Read on scroll", isOn: $postLinkDefSettings.readOnScroll)
          Toggle("Hide read posts", isOn: $postLinkDefSettings.hideOnRead)
          Toggle("Blur NSFW in opened posts", isOn: $postPageDefSettings.blurNSFW)
          Toggle("Blur NSFW", isOn: $postLinkDefSettings.blurNSFW)
          Toggle("Save sort per subreddit", isOn: $subredditFeedDefSettings.perSubredditSort)
          Toggle("Open subreddit options on tap", isOn: $subredditFeedDefSettings.openOptionsOnTap)
          Toggle("Open media from feed", isOn: $postLinkDefSettings.isMediaTappable)
          
          
          Menu {
            ForEach(Array(SubListingSortOption.allCases), id: \.self) { opt in
              if let children = opt.meta.children {
                Menu {
                  ForEach(children, id: \.self.meta.apiValue) { child in
                    if let val = child.valueWithParent as? SubListingSortOption {
                      Button(child.meta.label, systemImage: child.meta.icon) {
                        subredditFeedDefSettings.preferredSort = val
                      }
                    }
                  }
                } label: {
                  Label(opt.meta.label, systemImage: opt.meta.icon)
                }
              } else {
                Button(opt.meta.label, systemImage: opt.meta.icon) {
                  subredditFeedDefSettings.preferredSort = opt
                }
              }
            }
          } label: {
            Button { } label: {
              HStack {
                Text("Default post sorting")
                Spacer()
                Image(systemName: subredditFeedDefSettings.preferredSort.meta.icon)
                  .foregroundStyle(Color.accentColor)
              }
              .foregroundColor(.primary)
            }
          }
          
          
          Menu {
            ForEach(Array(SubListingSortOption.allCases), id: \.self) { opt in
              if let children = opt.meta.children {
                Menu {
                  ForEach(children, id: \.self.meta.apiValue) { child in
                    if let val = child.valueWithParent as? SubListingSortOption {
                      Button(child.meta.label, systemImage: child.meta.icon) {
                        subredditFeedDefSettings.preferredSearchSort = val
                      }
                    }
                  }
                } label: {
                  Label(opt.meta.label, systemImage: opt.meta.icon)
                }
              } else {
                Button(opt.meta.label, systemImage: opt.meta.icon) {
                  subredditFeedDefSettings.preferredSearchSort = opt
                }
              }
            }
          } label: {
            Button { } label: {
              HStack {
                Text("Default search sorting")
                Spacer()
                Image(systemName: subredditFeedDefSettings.preferredSearchSort.meta.icon)
                  .foregroundStyle(Color.accentColor)
              }
              .foregroundColor(.primary)
            }
          }
          
          
          VStack(alignment: .leading) {
            HStack {
              Text("Max Posts Image Height")
              Spacer()
              Text(postLinkDefSettings.maxMediaHeightScreenPercentage == 110 ? "Original" : "\(Int(postLinkDefSettings.maxMediaHeightScreenPercentage))%")
                .opacity(0.6)
            }
            Slider(value: $postLinkDefSettings.maxMediaHeightScreenPercentage, in: 10...110, step: 10)
          }
        }
        .themedListSection()
        
        Section("Comments") {
          WSNavigationLink(.setting(.commentSwipe), "Comments Swipe Settings")
          
          Picker("Comments Sorting", selection: $commentsSectionDefSettings.preferredSort) {
            ForEach(CommentSortOption.allCases, id: \.self) { val in
              Label(val.rawVal.id.capitalized, systemImage: val.rawVal.icon)
            }
          }
          
          Toggle("Collapse AutoModerator comments", isOn: $commentsSectionDefSettings.collapseAutoModerator)
          Toggle("Comment skipper button", isOn: $commentsSectionDefSettings.commentSkipper)
          Toggle("Save comment sort per post", isOn: $postPageDefSettings.perPostSort)
        }
        
      }
      .themedListSection()
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("Behavior")
    .navigationBarTitleDisplayMode(.inline)
  }
}
//
//struct Behavior_Previews: PreviewProvider {
//    static var previews: some View {
//        Behavior()
//    }
//}
