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
  
  init(feedId: String, showSubInPosts: Bool = false, title: String, theme: ThemeBG, fetch: @escaping FeedItemsManager<S>.ItemsFetchFn, @ViewBuilder header: @escaping () -> Header = { EmptyView() }, @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }, initialSorting: S, disableSearch: Bool = true, subreddit: Subreddit? = nil) {
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
  
  var body: some View {
    let shallowCachedFilters = filters.map { $0.getShallow() }
    GeometryReader { geo in
      List {
        header()
        
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
            Text("abor")
          case .error:
            Text("lamor")
          case .endOfFeed, .items:
            Section {
              ForEach(Array(itemsManager.entities.enumerated()), id: \.element) { i, el in
                Group {
                  switch el {
                  case .post(let post):
                    if let winstonData = post.winstonData, let sub = winstonData.subreddit ?? subreddit {
                      let isThereDivider = selectedTheme.postLinks.divider.style != .no
                      let paddingH = selectedTheme.postLinks.theme.outerHPadding
                      let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
                      PostLink(id: post.id, theme: selectedTheme.postLinks, showSub: showSubInPosts, compactPerSubreddit: feedDefSettings.compactPerSubreddit[sub.id], contentWidth: contentWidth, defSettings: postLinkDefSettings)
                        .environment(\.contextPost, post)
                        .environment(\.contextSubreddit, sub)
                        .environment(\.contextPostWinstonData, winstonData)
                        .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
                    }
                  case .subreddit(let sub): SubredditLink(sub: sub)
                  case .multi(_): EmptyView()
                  case .comment(let comment):
                    VStack {
                      ShortCommentPostLink(comment: comment)
                        .padding()
                      if let commentWinstonData = comment.winstonData {
                        CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                      }
                    }
                    .background(PostLinkBG(theme: theme, stickied: false, secondary: false))
                    .mask(RR(theme.theme.cornerRadius, Color.black))
                  case .user(let user): UserLink(user: user)
                  case .message(let message):
                    MessageLink(message: message)
                      .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                  }
                }
                .onAppear { Task { await itemsManager.iAppeared🥳(entity: el, index: i) } }
                .onDisappear { Task { await itemsManager.imGone🙁(entity: el, index: i) } }
              }
            }
          }
          
          if itemsManager.displayMode == .items {
            Section {
              ProgressView()
                .frame(maxWidth: .infinity, minHeight: 150)
                .id("loading-more-spinner-\(itemsManager.entities.count)")
            }
          }
          
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        
        footer()
      }
      .themedListBG(theme)
      .scrollIndicators(.never)
      .listStyle(.plain)
      .navigationTitle(title)
      .environment(\.defaultMinListRowHeight, 1)
      .searchable(text: $itemsManager.searchQuery.value)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          HStack {
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
              Image(systemName: itemsManager.sorting.meta.icon)
                .foregroundColor(Color.accentColor)
                .fontSize(17, .bold)
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
      .floatingMenu(subId: subreddit?.id, filters: Array(shallowCachedFilters), selectedFilter: $itemsManager.selectedFilter)
      //    .onChange(of: itemsManager.selectedFilter) { searchEnabled = $1?.type != .custom }
      .onChange(of: itemsManager.searchQuery.value) { itemsManager.displayMode = .loading }
      .onChange(of: subredditFeedDefSettings.chunkLoadSize) { itemsManager.chunkSize = $1 }
      .task(id: [itemsManager.searchQuery.debounced, itemsManager.selectedFilter?.text, itemsManager.sorting.meta.apiValue]) {
        if itemsManager.displayMode != .loading { return }
        await itemsManager.fetchCaller(loadingMore: false)
        if let subreddit, !fetchedFilters {
          await subreddit.fetchAndCacheFlairs()
          fetchedFilters = true
        }
      }
    }
  }
}
