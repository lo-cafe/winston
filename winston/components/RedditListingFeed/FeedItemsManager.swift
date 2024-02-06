//
//  FeedItemsManager.swift
//  winston
//
//  Created by Igor Marcossi on 26/01/24.
//

import SwiftUI
import Defaults
import Nuke

@Observable
class FeedItemsManager<S> {
  typealias ItemsFetchFn = (_ lastElementId: String?, _ sorting: S?, _ searchQuery: String?, _ flair: String?) async -> (entities: [RedditEntityType]?, after: String?)?
  
  enum DisplayMode: String { case loading, empty, items, endOfFeed, error }
  
  private var currentTask: Task<(), Never>? = nil
  var displayMode: DisplayMode = .loading
  var loadingPinned = false
  var pinnedPosts: [Post] = []
  var entities: [RedditEntityType] = []
  var loadedEntitiesIds: Set<String> = []
  var lastElementId: String? = nil
  var sorting: S? {
    willSet { withAnimation { displayMode = .loading } }
  }
  var searchQuery = Debouncer("")
  var selectedFilter: ShallowCachedFilter? {
    willSet { withAnimation { displayMode = .loading } }
  }
  var chunkSize: Int
  private var onScreenEntities: [(entity: RedditEntityType, index: Int)] = []
  private var fetchFn: ItemsFetchFn
  private let prefetchRange = 2
  
  init(sorting: S?, fetchFn: @escaping ItemsFetchFn) {
    self.sorting = sorting
    self.fetchFn = fetchFn
    self.chunkSize = Defaults[.SubredditFeedDefSettings].chunkLoadSize
  }
  
  func fetchCaller(loadingMore: Bool) async {
    if !loadingMore, let currentTask, !currentTask.isCancelled {
      currentTask.cancel()
    }
//    if displayMode != .loading { displayMode = .loading }
    let lastElementId = loadingMore ? self.lastElementId : nil
    let searchQuery = selectedFilter?.type == .custom ? selectedFilter?.text : searchQuery.debounced.isEmpty ? nil : searchQuery.debounced
    let filter = selectedFilter?.type != .custom ? selectedFilter?.text : nil

    if let (fetchedEntities, after) = await fetchFn(lastElementId, sorting, searchQuery, filter), let fetchedEntities {
      
      if !loadingMore {
        var newLoadedEntitiesIds = Set<String>()
        fetchedEntities.forEach { ent in
          newLoadedEntitiesIds.insert(ent.fullname)
        }
        withAnimation {
          displayMode = fetchedEntities.count == 0 ? .empty : fetchedEntities.count < chunkSize ? .endOfFeed : .items
          entities = fetchedEntities
//          self.lastElementId = fetchedEntities.count == 0 ? nil : fetchedEntities[fetchedEntities.count - 1].fullname
          self.lastElementId = after
          loadedEntitiesIds = newLoadedEntitiesIds
        }
        return
      }
      
      var newLoadedEntitiesIds = loadedEntitiesIds
      var newEntities = entities
      
      fetchedEntities.forEach { ent in
        if newLoadedEntitiesIds.contains(ent.fullname) { return }
        newLoadedEntitiesIds.insert(ent.fullname)
        newEntities.append(ent)
      }
                  
      withAnimation {
        displayMode = fetchedEntities.count < chunkSize ? .endOfFeed : .items
        entities = newEntities
//        self.lastElementId = fetchedEntities.count == 0 ? nil : fetchedEntities[fetchedEntities.count - 1].fullname
        self.lastElementId = after
        loadedEntitiesIds = newLoadedEntitiesIds
      }
      
    } else {
      withAnimation {
        displayMode = .error
      }
    }
    self.currentTask = nil
  }
  
  func iAppeared🥳(entity: RedditEntityType, index: Int) async {
    if displayMode != .endOfFeed, entities.count > 0, index >= entities.count - 7, currentTask == nil {
      self.currentTask = Task { await fetchCaller(loadingMore: true) }
    }
    
    let start = index - prefetchRange < 0 ? 0 : index - prefetchRange
    let end = index + (prefetchRange + 1) > entities.count ? entities.count : index + (prefetchRange + 1)
    let toPrefetch = Array(entities[start..<end])
    let reqs = getImgReqsFrom(toPrefetch)

    Post.prefetcher.startPrefetching(with: reqs)
  }
  
  func imGone🙁(entity: RedditEntityType, index: Int) async {
    let reqs = getImgReqsFrom([entity])
    Post.prefetcher.stopPrefetching(with: reqs)
  }
  
  private func getImgReqsFrom(_ entities: [RedditEntityType]) -> [ImageRequest] {
    entities.reduce([] as [ImageRequest]) { partialResult, entity in
      var newPartial = partialResult
      switch entity {
      case .post(let post):
        if let avatarImgReq = post.winstonData?.avatarImageRequest {
          newPartial.append(avatarImgReq)
        }
        if let extractedMedia = post.winstonData?.extractedMedia {
          switch extractedMedia {
          case .comment(let comment):
            break
          case .imgs(let imgsExtracted):
            newPartial = newPartial + imgsExtracted.map { $0.request }
          case .link(let link):
            if let imgReq = link.imageReq {
              newPartial.append(imgReq)
            }
            break
          case .video(let video):
            break
          case .yt(let video):
            newPartial.append(video.thumbnailRequest)
          case .streamable(_):
            break
          case .repost(_):
            break
          case .post(_):
            break
          case .subreddit(_):
            break
          case .user(_):
            break
          }
        }
        break
      default: break
      }
      return newPartial
    }
  }
}
