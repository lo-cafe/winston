//
//  UserView.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import SwiftUI
import NukeUI
import Defaults

//enum UserViewSections: Int {
//  case
//}

struct UserView: View {
  @StateObject var user: User
  @State private var lastActivities: [Either<Post, Comment>]?
  @State private var contentWidth: CGFloat = 0
  @State private var loadingOverview = true
  @State private var lastItemId: String? = nil
  @Environment(\.useTheme) private var selectedTheme
  @EnvironmentObject private var routerProxy: RouterProxy
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  @Default(.showSelfPostThumbnails) private var showSelfPostThumbnails
  
  @ObservedObject var avatarCache = Caches.avatars
  @Environment(\.colorScheme) private var cs
//  @Environment(\.contentWidth) private var contentWidth
  
  func refresh() async {
    await user.refetchUser()
    if let data = await user.refetchOverview() {
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
  
  func loadNextData() {
    Task {
      if let lastId = lastItemId, let overviewData = await user.refetchOverview(lastId) {
        await MainActor.run {
          withAnimation {
            lastActivities?.append(contentsOf: overviewData)
          }
        }
        
        if let lastItem = overviewData.last {
          lastItemId = getItemId(for: lastItem)
        }
      }
    }
  }
  
  func getItemId(for item: Either<Post, Comment>) -> String {
    // As per API doc: https://www.reddit.com/dev/api/#GET_user_{username}_overview
    switch item {
    case .first(let post):
      return "\(Post.prefix)_\(post.id)"
      
    case .second(let comment):
      return "\(Comment.prefix)_\(comment.id)"
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
            }
            
            VStack {
              HStack {
                if let postKarma = data.link_karma {
                  DataBlock(icon: "highlighter", label: "Post karma", value: "\(formatBigNumber(postKarma))")
                    .transition(.opacity)
                }
                
                if let commentKarma = data.comment_karma {
                  DataBlock(icon: "checkmark.message.fill", label: "Comment karma", value: "\(formatBigNumber(commentKarma))")
                    .transition(.opacity)
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
          
          Text("Last activities")
            .fontSize(20, .bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
          
          if let lastActivities = lastActivities {
            ForEach(Array(lastActivities.enumerated()), id: \.self.element.hashValue) { i, item in
              VStack(spacing: 0) {
                switch item {
                case .first(let post):
                  if let postData = post.data, let winstonData = post.winstonData {
//                    SwipeRevolution(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post) { controller in
                      PostLink(
                        id: post.id,
                        controller: nil,
                        //                controller: nil,
                        avatarRequest: avatarCache.cache[postData.author_fullname ?? ""]?.data,
                        repostAvatarRequest: getRepostAvatarRequest(post),
                        theme: selectedTheme.postLinks,
                        showSub: true,
                        routerProxy: routerProxy,
                        contentWidth: contentWidth,
                        blurPostLinkNSFW: blurPostLinkNSFW,
                        postSwipeActions: postSwipeActions,
                        showVotes: showVotes,
                        showSelfText: showSelfText,
                        readPostOnScroll: readPostOnScroll,
                        hideReadPosts: hideReadPosts,
                        showUpvoteRatio: showUpvoteRatio,
                        showSubsAtTop: showSubsAtTop,
                        showTitleAtTop: showTitleAtTop,
                        compact: compactMode,
                        thumbnailPositionRight: thumbnailPositionRight,
                        voteButtonPositionRight: voteButtonPositionRight,
                        showSelfPostThumbnails: showSelfPostThumbnails,
                        cs: cs
                      )
                      .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
//                    }
                    .environmentObject(post)
                    .environmentObject(Subreddit(id: postData.subreddit, api: user.redditAPI))
                    .environmentObject(winstonData)
                  }
                case .second(let comment):
                  VStack {
                    ShortCommentPostLink(comment: comment)
                    if let commentWinstonData = comment.winstonData {
                      CommentLink(lineLimit: 3, showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                      //                      .equatable()
                        .allowsHitTesting(false)
                    }
                  }
                  .padding(.horizontal, 12)
                  .padding(.top, 12)
                  .padding(.bottom, 10)
                  .themedListRowBG()
                  .mask(RR(20, Color.black))
                }
              }
              .onAppear { if lastActivities.count > 0 && (Int(Double(lastActivities.count) * 0.75) == i) { loadNextData() }}
            }
          }
          
          if lastItemId != nil || loadingOverview {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity, minHeight: 100 )
              .id("post-loading")
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
  }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
