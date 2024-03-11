//
//  SubredditData.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import Foundation
import CoreData
import Defaults
import SwiftUI
import SwiftData


typealias Subreddit = GenericRedditEntity<SubredditData, AnyHashable>

extension Subreddit {
  static var prefix = "t5"
  var selfPrefix: String { Self.prefix }
  
  convenience init(data: T) {
    self.init(data: data, typePrefix: "\(Subreddit.prefix)_")
  }
  
  convenience init(id: String) {
    self.init(id: id, typePrefix: "\(Subreddit.prefix)_")
  }
  
  convenience init(entity: CachedSub) {
    self.init(id: entity.uuid ?? UUID().uuidString, typePrefix: "\(Subreddit.prefix)_")
    self.data = SubredditData(entity: entity)
  }
  
  var isFeed: Bool { feedsAndSuch.contains(self.id) }
    
  /// Add a subreddit to the local like list
  /// This is a seperate list from reddits liked intenden for usage with subreddits a user wants to favorite but not subscribe to
  /// returns true if added to favorites and false if removed
  func localFavoriteToggle() -> Bool {
    var likedButNotSubbed = Defaults[.likedButNotSubbed]
    // If the user is not subscribed
    
    // If its already in liked remove it
    if likedButNotSubbed.contains(self) {
      likedButNotSubbed = likedButNotSubbed.filter{ $0.id != self.id }
      return false
    } else { // Else add it
      Defaults[.likedButNotSubbed].append(self)
      return true
    }
  }
  
  func favoriteToggle(entity: CachedSub? = nil) {
    if let entity = entity, let name = data?.display_name {
      let favoritedStatus = entity.user_has_favorited
      if let context = entity.managedObjectContext {
        entity.user_has_favorited = !favoritedStatus
        withAnimation {
          self.data?.user_has_favorited = !favoritedStatus
          try? context.save()
        }
        
        Task {
          let result = await RedditAPI.shared.favorite(!favoritedStatus, subName: name)
          if !result {
            entity.user_has_favorited = favoritedStatus
            withAnimation {
              self.data?.user_has_favorited = favoritedStatus
              try? context.save()
            }
          }
        }
      }
    }
  }
  
  func subscribeToggle(optimistic: Bool = false, _ cb: (()->())? = nil) {
    guard let currentCredentialID = RedditCredentialsManager.shared.selectedCredential?.id else { return }
    
    let context = PersistenceController.shared.container.viewContext
    
    if let data = data {
      @Sendable func doToggle() {
        let fetchRequest = NSFetchRequest<CachedSub>(entityName: "CachedSub")
        fetchRequest.predicate = NSPredicate(format: "winstonCredentialID == %@", currentCredentialID as CVarArg)
        guard let results = (context.performAndWait { return try? context.fetch(fetchRequest) }) else { return }
        let foundSub = context.performAndWait { results.first(where: { $0.name == self.data?.name }) }
        
        withAnimation {
          self.data?.user_is_subscriber?.toggle()
        }
        if let foundSub = foundSub { // when unsubscribe
          context.delete(foundSub)
        } else if let newData = self.data {
          context.performAndWait {
            _ = CachedSub(data: newData, context: context, credentialID: currentCredentialID)
          }
        }
      }
      
      //      let likedButNotSubbed = Defaults[.likedButNotSubbed]
      if optimistic {
        doToggle()
        context.performAndWait {
          withAnimation {
            try? context.save()
          }
        }
      }
      Task(priority: .background) {
        let result = await RedditAPI.shared.subscribe((self.data?.user_is_subscriber ?? false) ? (optimistic ? .sub : .unsub) : (optimistic ? .unsub : .sub), subFullname: data.name)
        context.performAndWait {
          if (result && !optimistic) || (!result && optimistic) {
            doToggle()
          }
          context.performAndWait {
            withAnimation {
              try? context.save()
            }
          }
          cb?()
        }
      }
    }
  }
  
  func refreshSubreddit() async {
    if let data = (await RedditAPI.shared.fetchSub(data?.display_name ?? id))?.data {
      await MainActor.run {
        withAnimation {
          self.data = data
        }
      }
    }
  }
  
  static func fetchAndCacheFlairsFrom(_ subID: String) async {
    if let flairs = await RedditAPI.shared.getFlairs(subID) {
      let context = PersistenceController.shared.container.viewContext
      let fetchRequest = NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
      fetchRequest.predicate = NSPredicate(format: "subID == %@", subID)
      
      let existentFlairs = await context.perform { try? context.fetch(fetchRequest) } ?? []
      
      flairs.forEach { flair in
        context.performAndWait {
          if let foundFlair = existentFlairs.first(where: { $0.text == flair.text }) {
            foundFlair.update(flair)
            return
          }
          
          _ = CachedFilter(context: context, subID: subID, flair)
        }
      }
      
      await context.perform {
        try? context.save()
      }
    }
  }
  
  func fetchAndCacheFlairs() async {
    await Self.fetchAndCacheFlairsFrom(self.data?.display_name ?? self.id)
  }
  
  func fetchRules() async -> RedditAPI.FetchSubRulesResponse? {
    if let data = await RedditAPI.shared.fetchSubRules(data?.display_name ?? id) {
      return data
    }
    return nil
  }
  
  func cacheFlairsFromPosts(_ entities: [RedditEntityType]) {
    let context = PersistenceController.shared.container.viewContext
    let bgContext = PersistenceController.shared.primaryBGContext
    
    let fetchRequest = CachedFilter.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "subID == %@", self.id)
    
    if let existentFilters = bgContext.performAndWait({ try? bgContext.fetch(fetchRequest) }) {
      entities.forEach { entity in
        if case .post(let post) = entity, let postData = post.data, let flairText = postData.link_flair_text {
          guard !bgContext.performAndWait({(existentFilters.contains { $0.text == flairText })}) else { return }
          context.performAndWait {
            let newFilter = CachedFilter(context: context)
            newFilter.subID = self.id
            newFilter.type = .modFlair
            newFilter.text = flairText
            newFilter.textColor = postData.link_flair_text_color
            newFilter.bgColor = postData.link_flair_background_color
          }
        }
      }
      context.performAndWait { try? context.save() }
    }
  }
  
  func fetchPosts(sort: SubListingSortOption = .best, after: String? = nil, searchText: String? = nil, contentWidth: CGFloat = .screenW, flair: String? = nil) async -> ([RedditEntityType]?, String?)? {
    let response = flair == nil && searchText == nil
    ? await RedditAPI.shared.fetchSubPosts(data?.url ?? (id == "home" ? "" : id), sort: sort, after: after)
    : await RedditAPI.shared.searchInSubreddit(data?.url ?? (id == "home" ? nil : id), RedditAPI.AdvancedPostsSearch(after: after, subreddit: data?.url ?? (id == "home" ? "" : id), flairs: flair == nil ? nil : [flair!], searchQuery: searchText, sortOption: sort))
    if let response, let data = response.0 {
      var isMixed = false
      let datas = data.compactMap {
        if case .second(_) = $0.data {
          isMixed = true
        }
        return $0.data
      }
      var entities = [RedditEntityType]()
      if isMixed {
        entities = datas.compactMap {
          return switch $0 {
          case .first(let postData):
              .post(.init(data: postData, contentWidth: contentWidth))
          case .second(let commentData):
              .comment(.init(data: commentData))
          }
        }
      } else {
        entities = Post.initMultiple(datas: data.compactMap {
          if case .first(let postData) = $0.data {
            return postData
          }
          return nil
        }, sub: self, contentWidth: contentWidth).map { .post($0) }
      }
      
      Task { [entities] in cacheFlairsFromPosts(entities) }
      return (entities, response.1)
    }
    return nil
  }
  
//  func fetchPinnedPosts() async -> [Post]? {
//    if let response = await RedditAPI.shared.fetchSubPosts(data?.url ?? (id == "home" ? "" : id), limit: 10, sort: .best, after: nil, searchText: nil, flair: nil), let data = response.0 {
//      return Post.initMultiple(datas: data.compactMap { $0.data?.stickied == true ? $0.data : nil }, sub: self, contentWidth: .screenW)
//    }
//    return nil
//  }
  
  func fetchSavedMixedMedia(after: String? = nil, searchText: String? = nil, contentWidth: CGFloat = .screenW) async -> [Either<Post, Comment>]? {
    // saved feed is a mix of posts and comments - logic needs to be handled separately
    if let savedMediaData = await RedditAPI.shared.fetchSavedPosts("saved", after: after, searchText: searchText) {
      await MainActor.run {
        self.loading = false
      }
      
      var comments: [Comment] = []
      
      let selectedTheme = InMemoryTheme.shared.currentTheme
      
      let returnData: [Either<Post, Comment>]? = savedMediaData.map {
        switch $0 {
        case .first(let postData):
          return .first(Post(data: postData, sub: self))
        case .second(let commentData):
          let comment = Comment(data: commentData)
          comments.append(comment)
          return .second(comment)
        }
      }
      
      Task(priority: .background) { [comments] in
        _ = await RedditAPI.shared.updateCommentsWithAvatar(comments: comments, avatarSize: selectedTheme.comments.theme.badge.avatar.size)
      }
      
      return returnData
    }
    return nil
  }
  
  func resetFlairs() {
    let context = PersistenceController.shared.container.newBackgroundContext()
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedFilter")
    fetchRequest.predicate = NSPredicate(format: "subID == %@ && type == 'flair'", self.id)
    
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    do {
      // Perform the batch delete
      try context.performAndWait {
        let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
        let deletedObjects: [AnyHashable: Any] = [ NSDeletedObjectsKey: deleteResult ]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
      }
    } catch {
      print("Error resetting flairs for \(self.id)")
    }
  }
}

struct CommentContributionSettings: Codable, Hashable {
  let allowed_media_types: [String]?
}

struct SubListingSort: Codable, Identifiable {
  var icon: String
  var value: String
  var id: String {
    value
  }
}

let ablocaq = Array(SubListingSortOption.TopListingSortOption.allCases)[0].valueWithParent

enum SubListingSortOption: Sorting {
  case best, hot, new, controversial, top(TopListingSortOption)
  
  var meta: SortingOption {
    switch self {
    case .best: SortingOption(icon: "trophy", label: "Best", apiValue: "best")
    case .controversial: SortingOption(icon: "figure.fencing", label: "Controversial", apiValue: "controversial")
    case .hot: SortingOption(icon: "flame", label: "Hot", apiValue: "hot")
    case .new: SortingOption(icon: "newspaper", label: "New", apiValue: "new")
    case .top(let subOption): SortingOption(icon: subOption.meta.icon, label: "Top", apiValue: "top/\(subOption.meta.apiValue)", children: Array(TopListingSortOption.allCases))
    }
  }
  
  enum TopListingSortOption: String, Sorting, CaseIterable {
    case hour, day, week, month, year, all

    var valueWithParent: (any Sorting)? {
      SubListingSortOption.top(self)
    }
    
    var meta: SortingOption {
      switch self {
      case .hour: SortingOption(icon: "clock", label: "Hour", apiValue: "hour")
      case .day: SortingOption(icon: "sun.max", label: "Day", apiValue: "day")
      case .week: SortingOption(icon: "clock.arrow.2.circlepath", label: "Week", apiValue: "week")
      case .month: SortingOption(icon: "calendar", label: "Month", apiValue: "month")
      case .year: SortingOption(icon: "globe.americas.fill", label: "Year", apiValue: "year")
      case .all: SortingOption(icon: "arrow.up.circle.badge.clock", label: "All", apiValue: "all")
      }
    }
  }
}

extension SubListingSortOption: CaseIterable {
  static var allCases: [SubListingSortOption] {
    return [.best, .hot, .new, .controversial, .top(.all)]
  }
}
