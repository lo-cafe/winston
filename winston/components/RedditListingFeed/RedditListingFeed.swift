//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 23/01/24.
//

import SwiftUI
import Defaults
import SwiftData

struct RedditListingFeed<Header: View, Footer: View, S: Sorting>: View {
  private var showSubInPosts: Bool
  private var feedId: String
  private var title: String
  private var theme: ThemeBG
  //  private var fetch: (_ force: Bool, _ lastElementId: String?, _ searchQuery: String?) async -> [RedditEntityType]?
  private var header: () -> Header
  private var footer: () -> Footer
  private var subreddit: Subreddit?
  private var disableSearch: Bool
  @Default(.SubredditFeedDefSettings) private var subredditFeedDefSettings
  @Default(.GeneralDefSettings) private var generalDefSettings
  
  init(feedId: String, showSubInPosts: Bool = false, title: String, theme: ThemeBG, fetch: @escaping FeedItemsManager<S>.ItemsFetchFn, @ViewBuilder header: @escaping () -> Header = { EmptyView() }, @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }, initialSorting: S? = nil, disableSearch: Bool = true, subreddit: Subreddit? = nil) where S == SubListingSortOption {
    self.showSubInPosts = showSubInPosts
    self.feedId = feedId
    self.title = title
    self.theme = theme
    self.header = header
    self.footer = footer
    self.subreddit = subreddit
    self.disableSearch = disableSearch
    self._itemsManager = .init(initialValue: FeedItemsManager(sorting: initialSorting, fetchFn: fetch))
    self._searchEnabled = .init(initialValue: disableSearch)
    self._filters = FetchRequest<CachedFilter>(sortDescriptors: [NSSortDescriptor(key: "text", ascending: true)], predicate: NSPredicate(format: "subID == %@", (subreddit?.data?.display_name ?? feedId) as CVarArg), animation: .default)
  }
  
  @FetchRequest private var filters: FetchedResults<CachedFilter>
  
  @State private var searchEnabled: Bool
  @SilentState private var fetchedFilters: Bool = false
  
  @State private var itemsManager: FeedItemsManager<S>
  
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  @Default(.SubredditFeedDefSettings) private var feedDefSettings
  
  func refetch() async {
//    if let subreddit, !feedsAndSuch.contains(subreddit.id) {
//      Task {
//        withAnimation { itemsManager.loadingPinned = true }
//        if let pinnedPosts = await subreddit.fetchPinnedPosts() {
//          itemsManager.pinnedPosts = pinnedPosts
//        }
//        withAnimation { itemsManager.loadingPinned = false }
//      }
//    }
    
    await itemsManager.fetchCaller(loadingMore: false)
    if let subreddit, !fetchedFilters {
      await subreddit.fetchAndCacheFlairs()
      fetchedFilters = true
    }
  }
  
  @ViewBuilder
  func getPinnedSection() -> some View {
    if itemsManager.displayMode != .loading, itemsManager.pinnedPosts.count > 0 || itemsManager.loadingPinned {
      let isThereDivider = selectedTheme.postLinks.divider.style != .no
      let paddingH = selectedTheme.postLinks.theme.outerHPadding
      let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
      Section("Pinned") {
        if itemsManager.loadingPinned {
          ProgressView().frame(maxWidth:.infinity, minHeight: 100)
        } else {
          ScrollView(.horizontal) {
            LazyHStack(spacing: paddingV * 2) {
              ForEach(itemsManager.pinnedPosts) { post in
                StickiedPostLink(post: post)
              }
            }
            .scrollTargetLayout()
            .padding(.horizontal, paddingH)
            .padding(.bottom, paddingV)
          }
          .scrollTargetBehavior(.viewAligned)
          .listRowInsets(.zero)
          .scrollIndicators(.hidden)
        }
      }
      .listRowInsets(EdgeInsets(top: 0, leading: paddingH, bottom: 0, trailing: paddingH))
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
    }
  }
  
  var body: some View {
    let shallowCachedFilters = filters.map { $0.getShallow() }
    let isThereDivider = selectedTheme.postLinks.divider.style != .no
    let paddingH = selectedTheme.postLinks.theme.outerHPadding
    let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
    GeometryReader { geo in
      List {
        header()
        
//        getPinnedSection()
        
        Group {
          switch itemsManager.displayMode {
          case .loading:
            Section {
              ProgressView()
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
                .padding(.bottom, 32)
                .id(UUID())
            }
          case .empty:
            Text("Nothing around here :(")
              .frame(maxWidth: .infinity)
          case .error, .endOfFeed, .items:
            
            Section {
              ForEach(Array(itemsManager.entities.enumerated()), id: \.element) { i, el in
                Group {
                  switch el {
                  case .post(let post):
                    if let winstonData = post.winstonData, let sub = winstonData.subreddit ?? subreddit {
                      PostLink(id: post.id, theme: selectedTheme.postLinks, showSub: showSubInPosts, compactPerSubreddit: feedDefSettings.compactPerSubreddit[sub.id], contentWidth: contentWidth, defSettings: postLinkDefSettings)
                        .environment(\.contextPost, post)
                        .environment(\.contextSubreddit, sub)
                        .environment(\.contextPostWinstonData, winstonData)
                        .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
                      
                      if isThereDivider && (i != (itemsManager.entities.count - 1)) {
                        NiceDivider(divider: selectedTheme.postLinks.divider)
                          .id("\(post.id)-divider")
                          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                      }
                    }
                  case .subreddit(let sub): SubredditLink(sub: sub)
                  case .multi(_): EmptyView()
                  case .comment(let comment):
                    VStack(spacing: 8) {
                      ShortCommentPostLink(comment: comment)
                        .padding(.horizontal, 12)
                      if let commentWinstonData = comment.winstonData {
                        CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                      }
                    }
                    .padding(.vertical, 12)
                    .background(PostLinkBG(theme: selectedTheme.postLinks.theme, stickied: false, secondary: false))
                    .mask(RR(selectedTheme.postLinks.theme.cornerRadius, Color.black))
                    .allowsHitTesting(false)
                    .contentShape(Rectangle())
                    .onTapGesture {
                      if let data = comment.data, let link_id = data.link_id, let subID = data.subreddit {
                        Nav.to(.reddit(.postHighlighted(Post(id: link_id, subID: subID), comment.id)))
                      }
                    }
                    .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
                  case .user(let user): UserLink(user: user)
                  case .message(let message):
                    let isThereDivider = selectedTheme.postLinks.divider.style != .no
                    let paddingH = selectedTheme.postLinks.theme.outerHPadding
                    let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
                    MessageLink(message: message)
                      .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
                    
                    if isThereDivider && (i != (itemsManager.entities.count - 1)) {
                      NiceDivider(divider: selectedTheme.postLinks.divider)
                        .id("\(message.id)-divider")
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                  }
                }
                .onAppear { Task { await itemsManager.iAppeared🥳(entity: el, index: i) } }
                .onDisappear { Task { await itemsManager.imGone🙁(entity: el, index: i) } }
              }
            }
            
            if itemsManager.displayMode == .endOfFeed {
              Section {
                EndOfFeedView()
              }
            }
            
            if itemsManager.displayMode == .error {
              Section {
                VStack {
                  Text("There was an error")
                  
                  Button("Manually reload", systemImage: "arrow.clockwise") {
                    withAnimation {
                      itemsManager.displayMode = .items
                    }
                    Task { await itemsManager.fetchCaller(loadingMore: true) }
                  }
                  .buttonStyle(.actionSecondary)
                }
                .frame(maxWidth: .infinity)
                .compositingGroup()
                .opacity(0.5)
                .id("error-load-more-manual")
              }
            }
            
            //          default: EmptyView()
          }
          
          if itemsManager.displayMode == .items {
            Section {
              ProgressView()
                .frame(maxWidth: .infinity, minHeight: 150)
                .id(UUID())
            }
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        
        footer()
      }
      .themedListBG(theme)
      .if(!disableSearch) { $0.searchable(text: $itemsManager.searchQuery.value) }
      .scrollIndicators(.never)
      .listStyle(.plain)
      .navigationTitle(title)
      .environment(\.defaultMinListRowHeight, 1)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          HStack {
            if let currSort = itemsManager.sorting {
              Menu {
                ForEach(Array(S.allCases), id: \.self) { opt in
                  if let children = opt.meta.children {
                    Menu {
                      ForEach(children, id: \.self.meta.apiValue) { child in
                        if let val = child.valueWithParent as? S {
                          Button(child.meta.label, systemImage: child.meta.icon) {
                            itemsManager.sorting = val
                          }
                        }
                      }
                    } label: {
                      Label(opt.meta.label, systemImage: opt.meta.icon)
                    }
                  } else {
                    Button(opt.meta.label, systemImage: opt.meta.icon) {
                      itemsManager.sorting = opt
                    }
                  }
                }
              } label: {
                Image(systemName: currSort.meta.icon)
                  .foregroundColor(Color.accentColor)
                  .fontSize(17, .bold)
              }
            }
            //          .disabled(subreddit.id == "saved")
            //        }
            if let sub = subreddit, let data = sub.data {
              Button {
                Nav.to(.reddit(.subInfo(sub)))
              } label: {
                SubredditIcon(subredditIconKit: data.subredditIconKit)
              }
            }
          }
        }
      }
      .floatingMenu(subId: subreddit?.id, filters: shallowCachedFilters, selectedFilter: $itemsManager.selectedFilter)
      //    .onChange(of: itemsManager.selectedFilter) { searchEnabled = $1?.type != .custom }
      .refreshable { await refetch() }
      .onChange(of: generalDefSettings.redditCredentialSelectedID) { _, _ in
        withAnimation {
          itemsManager.entities = []
          itemsManager.displayMode = .loading
        }
        
        Task { await refetch() }
      }
      .onChange(of: itemsManager.searchQuery.value) { itemsManager.displayMode = .loading }
      .onChange(of: subredditFeedDefSettings.chunkLoadSize) { itemsManager.chunkSize = $1 }
      .task(id: [itemsManager.searchQuery.debounced, itemsManager.selectedFilter?.text, itemsManager.sorting?.meta.apiValue]) {
        if itemsManager.displayMode != .loading { return }
        await refetch()
      }
    }
  }
}
