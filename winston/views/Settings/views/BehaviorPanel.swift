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
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @Default(.openYoutubeApp) var openYoutubeApp
  @Default(.preferenceDefaultFeed) var preferenceDefaultFeed
  @Default(.useAuth) var useAuth
  @Default(.preferredSort) var preferredSort
  @Default(.preferredSearchSort) var preferredSearchSort
  @Default(.preferredCommentSort) var preferredCommentSort
  @Default(.blurPostLinkNSFW) var blurPostLinkNSFW
  @Default(.blurPostNSFW) var blurPostNSFW
  @Default(.collapseAutoModerator) var collapseAutoModerator
  @Default(.readPostOnScroll) var readPostOnScroll
  @Default(.hideReadPosts) var hideReadPosts
  @Default(.enableSwipeAnywhere) var enableSwipeAnywhere
  @Default(.autoPlayVideos) var autoPlayVideos
  @Default(.loopVideos) private var loopVideos
  @Default(.lightboxViewsPost) private var lightboxViewsPost
  @Default(.openLinksInSafari) private var openLinksInSafari
  @Default(.feedPostsLoadLimit) private var feedPostsLoadLimit
  @Default(.perSubredditSort) private var perSubredditSort
  @Default(.perPostSort) private var perPostSort
  @Default(.doLiveText) var doLiveText

  
  @Environment(\.useTheme) private var theme
  @State private var imageAnalyzerSupport: Bool = true
  var body: some View {
    List {
      
      Section("General") {
        Group {
          Toggle("Open links in Safari", isOn: $openLinksInSafari)
          Toggle("Open Youtube Videos Externally", isOn: $openYoutubeApp)            
          let auth_type = Biometrics().biometricType()
          Toggle("Lock Winston With \(auth_type)", isOn: $useAuth)

          VStack{
            Toggle("Live Text Analyzer", isOn: $doLiveText)
              .disabled(!imageAnalyzerSupport)
              .onAppear{
                imageAnalyzerSupport = ImageAnalyzer.isSupported
                if !ImageAnalyzer.isSupported {
                  doLiveText = false
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
          Picker("Default Launch Feed", selection: $preferenceDefaultFeed) {
            Text("Home").tag("home")
            Text("Popular").tag("popular")
            Text("All").tag("all")
            Text("Subscription List").tag("subList")
          }
          .pickerStyle(DefaultPickerStyle())
        }
        .themedListRowBG(enablePadding: true)

        WSNavigationLink(SettingsPages.filteredSubreddits, "Filtered Subreddits")
      }
      .themedListDividers()
      
      Section {
        LabeledSlider(label: "Loading limit", value: Binding(get: { CGFloat(feedPostsLoadLimit) }, set: { val in feedPostsLoadLimit = Int(val) }), range: 15...100)
          .themedListRowBG(enablePadding: true)
      } footer: {
        Text("Sets how many posts to load per chunk (loads more on scroll)")
      }
      .themedListDividers()
      
      Section {
        Toggle("Navigation everywhere", isOn: $enableSwipeAnywhere)
          .themedListRowBG(enablePadding: true)
      } footer: {
        Text("This will allow you to do go back by swiping anywhere in the screen, but will disable post and comments swipe gestures.")
          .padding(.bottom)
      }
      .themedListDividers()
      
      Section("Posts") {
        WSNavigationLink(SettingsPages.postSwipe, "Posts swipe settings")
        Group {
          Toggle("Loop videos", isOn: $loopVideos)
          Toggle("Autoplay videos (muted)", isOn: $autoPlayVideos)
          Toggle("Read on preview media", isOn: $lightboxViewsPost)
          Toggle("Read on scroll", isOn: $readPostOnScroll)
          Toggle("Hide read posts", isOn: $hideReadPosts)
          Toggle("Blur NSFW in opened posts", isOn: $blurPostNSFW)
          Toggle("Blur NSFW", isOn: $blurPostLinkNSFW)
          Toggle("Save sort per subreddit", isOn: $perSubredditSort)
          Menu {
            ForEach(SubListingSortOption.allCases) { opt in
              if case .top(_) = opt {
                Menu {
                  ForEach(SubListingSortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
                    Button {
                      preferredSort = .top(topOpt)
                    } label: {
                      HStack {
                        Text(topOpt.rawValue.capitalized)
                        Spacer()
                        Image(systemName: topOpt.icon)
                      }
                    }
                  }
                } label: {
                  Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                }
              } else {
                Button {
                  preferredSort = opt
                } label: {
                  HStack {
                    Text(opt.rawVal.value.capitalized)
                    Spacer()
                    Image(systemName: opt.rawVal.icon)
                  }
                }
              }
            }
          } label: {
            Button { } label: {
              HStack {
                Text("Default post sorting")
                Spacer()
                Image(systemName: preferredSort.rawVal.icon)
              }
              .foregroundColor(.primary)
            }
          }
            
          Menu {
            ForEach(SubListingSortOption.allCases) { opt in
              if case .top(_) = opt {
                Menu {
                  ForEach(SubListingSortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
                    Button {
                      preferredSearchSort = .top(topOpt)
                    } label: {
                      HStack {
                        Text(topOpt.rawValue.capitalized)
                        Spacer()
                        Image(systemName: topOpt.icon)
                      }
                    }
                  }
                } label: {
                  Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                }
              } else {
                Button {
                  preferredSearchSort = opt
                } label: {
                  HStack {
                    Text(opt.rawVal.value.capitalized)
                    Spacer()
                    Image(systemName: opt.rawVal.icon)
                  }
                }
              }
            }
          } label: {
            Button { } label: {
              HStack {
                Text("Default search sorting")
                Spacer()
                Image(systemName: preferredSearchSort.rawVal.icon)
              }
              .foregroundColor(.primary)
            }
          }
          
          VStack(alignment: .leading) {
            HStack {
              Text("Max Posts Image Height")
              Spacer()
              Text(maxPostLinkImageHeightPercentage == 110 ? "Original" : "\(Int(maxPostLinkImageHeightPercentage))%")
                .opacity(0.6)
            }
            Slider(value: $maxPostLinkImageHeightPercentage, in: 10...110, step: 10)
          }
        }
        .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      
      Section("Comments") {
        WSNavigationLink(SettingsPages.commentSwipe, "Comments Swipe Settings")
        
        Group {
          Picker("Comments Sorting", selection: $preferredCommentSort) {
            ForEach(CommentSortOption.allCases, id: \.self) { val in
              Label(val.rawVal.id.capitalized, systemImage: val.rawVal.icon)
            }
          }
          
          Toggle("Collapse AutoModerator comments", isOn: $collapseAutoModerator)
          Toggle("Save comment sort per post", isOn: $perPostSort)

        }
        .themedListRowBG(enablePadding: true)
      }
      .themedListDividers()
      
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
