//
//  UserView.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import NukeUI
import Defaults

struct UserViewContextPreview: View {
  var author: String
  var body: some View {
    NavigationStack { UserView(user: User(id: author)) }
  }
}

struct UserView: View {
  @StateObject var user: User
  @State private var lastActivities: [Either<Post, Comment>]?
  @State private var contentWidth: CGFloat = 0
  @State private var loadingOverview = true
  @State private var lastItemId: String? = nil
  @Environment(\.useTheme) private var selectedTheme
  
  @State private var dataTypeFilter: String = "" // Handles filtering for only posts or only comments.
  @State private var loadNextData: Bool = false
  
  @ObservedObject var avatarCache = Caches.avatars
  @Environment(\.colorScheme) private var cs
  //  @Environment(\.contentWidth) private var contentWidth
  
  func refresh() async {
    await user.refetchUser()
    if let data = await user.refetchOverview(dataTypeFilter) {
      await MainActor.run {
        withAnimation {
          loadingOverview = false
          lastActivities = data
        }
      }
      
      await user.redditAPI.updateOverviewSubjectsWithAvatar(subjects: data, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size)
      
      if let lastItem = data.last {
        lastItemId = getItemId(for: lastItem)
      }
    }
  }
  
  func getNextData() {
    Task {
      if let lastId = lastItemId, let overviewData = await user.refetchOverview(dataTypeFilter, lastId) {
        await MainActor.run {
          withAnimation {
            lastActivities?.append(contentsOf: overviewData)
          }
        }
        
        await user.redditAPI.updateOverviewSubjectsWithAvatar(subjects: overviewData, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size)
        
        if let lastItem = overviewData.last {
          lastItemId = getItemId(for: lastItem)
        }
      }
    }
  }
  
  func getRepostAvatarRequest(_ post: Post?) -> ImageRequest? {
    if let post = post, case .repost(let repost) = post.winstonData?.extractedMedia, let repostAuthorFullname = repost.data?.author_fullname {
      return avatarCache.cache[repostAuthorFullname]?.data
    }
    return nil
  }
  
  var body: some View {
    List {
      if let data = user.data {
        Group {
          VStack(spacing: 16) {
            ZStack {
              if let bannerImgFull = data.subreddit?.banner_img, !bannerImgFull.isEmpty, let bannerImg = URL(string: String(bannerImgFull.split(separator: "?")[0])) {
                URLImage(url: bannerImg)
                  .scaledToFill()
                  .frame(width: contentWidth, height: 160)
                  .mask(RR(16, Color.black))
              }
              if let iconFull = data.subreddit?.icon_img, iconFull != "", let icon = URL(string: String(iconFull.split(separator: "?")[0])) {
                
                URLImage(url: icon)
                  .scaledToFill()
                  .frame(width: 125, height: 125)
                  .mask(Circle())
                  .offset(y: data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 80)
              }
            }
            .frame(maxWidth: .infinity)
            .background(
              GeometryReader { geo in
                Color.clear.onAppear { contentWidth = geo.size.width }
              }
            )
            .padding(.bottom, data.subreddit?.banner_img == "" || data.subreddit?.banner_img == nil ? 0 : 78)
            
            if let description = data.subreddit?.public_description {
              Text((description).md())
                .fontSize(15)
                .multilineTextAlignment(.center)
            }
            
            VStack {
              HStack {
                if let postKarma = data.link_karma {
                  DataBlock(icon: "highlighter", label: "Post karma",
                            value: "\(formatBigNumber(postKarma))") // maybe switch this to use the theme colors?
                  .transition(.opacity)
                  .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                      if dataTypeFilter == "posts" {
                        dataTypeFilter = ""
                      } else {
                        dataTypeFilter = "posts"
                      }
                    }
                  }
                  .overlay(dataTypeFilter == "posts" ?
                           Color.accentColor.opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .allowsHitTesting(false)
                           : nil)
                }
                
                if let commentKarma = data.comment_karma {
                  DataBlock(icon: "checkmark.message.fill", label: "Comment karma", value: "\(formatBigNumber(commentKarma))")
                    .transition(.opacity)
                    .onTapGesture {
                      withAnimation(.easeInOut(duration: 0.2)) {
                        if dataTypeFilter == "comments" {
                          dataTypeFilter = ""
                        } else {
                          dataTypeFilter = "comments"
                        }
                      }
                    }
                    .overlay(dataTypeFilter == "comments" ?
                             Color.accentColor.opacity(0.2)
                      .clipShape(RoundedRectangle(cornerRadius: 20))
                      .allowsHitTesting(false)
                             : nil)
                }
              }
              if let created = data.created {
                DataBlock(icon: "star.fill", label: "User since", value: "\(Date(timeIntervalSince1970: TimeInterval(created)).toFormat("MMM dd, yyyy"))")
                  .transition(.opacity)
              }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .transition(.opacity)
          }
          
          Text(dataTypeFilter.isEmpty ? "Latest activity" : "Latest " + dataTypeFilter)
            .fontSize(20, .bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
          
          if let lastActivities = lastActivities {
            ForEach(Array(lastActivities.enumerated()), id: \.element) { i, item in
              MixedContentLink(content: item, theme: selectedTheme.postLinks)
                .onAppear {
                  if(lastActivities.count - 7 == i) {
                    getNextData()
                  }
                }
              
              if selectedTheme.postLinks.divider.style != .no && i != (lastActivities.count - 1) {
                NiceDivider(divider: selectedTheme.postLinks.divider)
                  .id("user-view-\(i)-divider")
                  .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
              }
            }
          }
          
          if lastItemId != nil || loadingOverview {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: 100 )
              .id("user-loading")
              .id(UUID()) // spawns unique spinner, swiftui bug.
          }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .transition(.opacity)
      }
    }
    .loader(user.data == nil)
    .themedListBG(selectedTheme.lists.bg)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .refreshable {
      await refresh()
    }
    .navigationTitle(user.data?.name ?? "Loading...")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task(priority: .background) {
        if user.data == nil || lastActivities == nil {
          await refresh()
        }
      }
    }
    .onChange(of: dataTypeFilter) { _ in
      withAnimation {
        lastActivities?.removeAll()
        loadingOverview = true
      }
      
      Task {
        await refresh()
      }
    }
  }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
