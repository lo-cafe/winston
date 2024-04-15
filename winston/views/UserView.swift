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
    var user: User
    @State private var lastActivities: [Either<Post, Comment>]?
    @State private var contentWidth: CGFloat = 0
    @State private var loadingOverview = true
    @State private var lastItemId: String? = nil
    @Default(.SubredditFeedDefSettings) private var subFeedSettings
    @Environment(\.useTheme) private var selectedTheme
    
    @State private var dataTypeFilter: String = "" // Handles filtering for only posts or only comments.
    @State private var forceRefresh = false
    @State private var loadNextData: Bool = false
    
    func fetcher(_ after: String?, _ sorting: SubListingSortOption?, _ searchQuery: String?, _ flair: String?) async -> ([RedditEntityType]?, String?)? {
        if let overviewDataResult = await user.refetchOverview(dataTypeFilter, after), let overviewData = overviewDataResult.0 {
            Task { await user.redditAPI.updateOverviewSubjectsWithAvatar(subjects: overviewData, avatarSize: selectedTheme.postLinks.theme.badge.avatar.size) }
            
            let newData: [RedditEntityType]? = overviewData.compactMap { if case .first(let post) = $0 { return .post(post) } else if case .second(let comment) = $0 { return .comment(comment) }; return nil }
            
            return (newData, overviewDataResult.1)
        }
        return nil
    }
    
    var body: some View {
        
        RedditListingFeed(feedId: user.fullname, title: "\(subFeedSettings.showPrefixOnFeedTitle ? "u/" : "")\(user.data?.name ?? "Loading...")", theme: selectedTheme.lists.bg, fetch: fetcher, header: {
            VStack(spacing: 16) {
                if let data = user.data {
                    Group {
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
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .transition(.opacity)
        }, disableSearch: true, forceRefresh: $forceRefresh)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if user.data == nil {
                await user.refetchUser()
            }
        }
        .onChange(of: dataTypeFilter) { _, _ in
            forceRefresh = true
        }
    }
}
