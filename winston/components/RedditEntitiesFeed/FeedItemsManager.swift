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
  typealias ItemsFetchFn = (_ lastElementId: String?, _ sorting: S, _ searchQuery: String?, _ flair: String?) async -> [RedditEntityType]?
  
  enum DisplayMode: String { case loading, empty, items, endOfFeed, error }
  
  var displayMode: DisplayMode = .loading
  var entities: [RedditEntityType] = []
  var loadedEntitiesIds: Set<String> = []
  var lastElementId: String? = nil
  var sorting: S {
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
  
  init(sorting: S, fetchFn: @escaping ItemsFetchFn) {
    self.sorting = sorting
    self.fetchFn = fetchFn
    self.chunkSize = Defaults[.SubredditFeedDefSettings].chunkLoadSize
  }
  
  func fetchCaller(loadingMore: Bool) async {
//    if displayMode != .loading { displayMode = .loading }
    let lastElementId = loadingMore ? self.lastElementId : nil
    let searchQuery = selectedFilter?.type == .custom ? selectedFilter?.text : searchQuery.debounced.isEmpty ? nil : searchQuery.debounced
    let filter = selectedFilter?.type != .custom ? selectedFilter?.text : nil
    if let fetchedEntities = await fetchFn(lastElementId, sorting, searchQuery, filter) {
      var newEntities = !loadingMore ? fetchedEntities : entities
      var newLoadedEntitiesIds = !loadingMore ? [] : loadedEntitiesIds
      var newLastElementId = !loadingMore ? nil : lastElementId
      
      fetchedEntities.forEach { entity in
        if !loadingMore || !loadedEntitiesIds.contains(entity.id) {
          if loadingMore { newEntities.append(entity) }
          newLoadedEntitiesIds.insert(entity.id)
        }
      }
      
      if !newEntities.isEmpty {
        let lastEl = newEntities[newEntities.count - 1]
        newLastElementId = lastEl.selfPrefix + "_" + lastEl.id
      }
      
      print(newEntities)
      withAnimation {
        displayMode = newEntities.count > 0 ? newEntities.count < chunkSize ? .endOfFeed : .items : entities.count > 0 ? .endOfFeed : .empty
        entities = newEntities
        self.lastElementId = newLastElementId
        loadedEntitiesIds = newLoadedEntitiesIds
      }
    } else {
      withAnimation {
        displayMode = .error
      }
    }
  }
  
  func iAppeared🥳(_ entity: (entity: RedditEntityType, index: Int)) async {
    if entity.index == entities.count - 7 {
      Task { await fetchCaller(loadingMore: true) }
    }
    
    let start = entity.index - prefetchRange < 0 ? 0 : entity.index - prefetchRange
    let end = entity.index + (prefetchRange + 1) > entities.count ? entities.count : entity.index + (prefetchRange + 1)
    let toPrefetch = Array(entities[start..<end])
    var reqs = getImgReqsFrom(toPrefetch)

    Post.prefetcher.startPrefetching(with: reqs)
  }
  
  func imGone🙁(_ entityTouple: (entity: RedditEntityType, index: Int)) async {
    let reqs = getImgReqsFrom([entityTouple.entity])
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
