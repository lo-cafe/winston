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
  
  func refetch() async {
    await itemsManager.fetchCaller(loadingMore: false)
    if let subreddit, !fetchedFilters {
      await subreddit.fetchAndCacheFlairs()
      fetchedFilters = true
    }
  }
  
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
            Text("Nothing around here :(")
              .frame(maxWidth: .infinity)
          case .error, .endOfFeed, .items:
            
            Section {
              ForEach(Array(itemsManager.entities.enumerated()), id: \.element) { i, el in
                RedditEntityView(
                  entity: el,
                  subreddit: subreddit,
                  isLastItem: i != (itemsManager.entities.count - 1),
                  showSubInPosts: showSubInPosts
                )
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
