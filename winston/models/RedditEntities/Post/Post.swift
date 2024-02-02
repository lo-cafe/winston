//
//  PostData.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import Foundation
import Defaults
import SwiftUI
import Nuke
import CoreData
import YouTubePlayerKit
import Alamofire

typealias Post = GenericRedditEntity<PostData, PostWinstonData>

extension Post {
  static var prefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared, destination: .memoryCache, maxConcurrentRequestCount: 10)
  static var prefix = "t3"
  var selfPrefix: String { Self.prefix }
  
  convenience init(data: T, sub: Subreddit? = nil, contentWidth: Double = .screenW, secondary: Bool = false, imgPriority: ImageRequest.Priority = .low, theme: WinstonTheme? = nil, fetchAvatar: Bool = true) {
    let theme = theme ?? InMemoryTheme.shared.currentTheme
    self.init(data: data, typePrefix: "\(Post.prefix)_")
    setupWinstonData(data: data, contentWidth: contentWidth, secondary: secondary, theme: theme, sub: sub, fetchAvatar: fetchAvatar)
  }
  
  convenience init(id: String, sub: Subreddit? = nil) {
    self.init(id: id, typePrefix: "\(Post.prefix)_")
    let newWinstonData = PostWinstonData()
    newWinstonData.subreddit = sub
    self.winstonData = newWinstonData
  }
  
  convenience init(id: String, subID: String) {
    self.init(id: id, typePrefix: "\(Post.prefix)_")
    let newWinstonData = PostWinstonData()
    newWinstonData._strongSubreddit = Subreddit(id: subID)
    self.winstonData = newWinstonData
  }
  
  func setupWinstonData(data: PostData? = nil, winstonData: PostWinstonData? = nil, contentWidth: Double = .screenW, secondary: Bool = false, theme: WinstonTheme, sub: Subreddit? = nil, fetchAvatar: Bool = true) {
    if let data = data ?? self.data {
      let compact = Defaults[.SubredditFeedDefSettings].compactPerSubreddit[sub?.id ?? data.subreddit_id ?? ""] ?? Defaults[.PostLinkDefSettings].compactMode.enabled
      if self.winstonData == nil { self.winstonData = .init() }
      
      self.winstonData?.permaURL = URL(string: "https://reddit.com\(data.permalink.urlEncoded)")
      
      var extractedMedia = mediaExtractor(compact: compact, contentWidth: contentWidth, data, theme: theme)
      var extractedMediaForcedNormal = mediaExtractor(compact: false, contentWidth: contentWidth, data, theme: theme)
      
      switch extractedMedia {
      case .streamable(let streamable):
        if let streamableCached = Caches.streamable.get(key: streamable.shortCode) {
          let sharedVideo = SharedVideo.get(url: streamableCached.url, size: streamableCached.size)
          
          extractedMedia = .video(sharedVideo)
          extractedMediaForcedNormal = .video(sharedVideo)
        } else {
          Task(priority: .background) {
            if let video = await self.loadStreamableMedia(streamable: streamable) {
              Caches.streamable.addKeyValue(key: streamable.shortCode, data: { StreamableCached(url: video.url, size: video.size) }, expires: Date().dateByAdding(1, .day).date)
              
              DispatchQueue.main.async {
                withAnimation {
                  self.winstonData?.extractedMedia = .video(video)
                  self.winstonData?.extractedMediaForcedNormal = .video(video)
                  
                  self.winstonData?.postDimensions = getPostDimensions(post: self, winstonData: self.winstonData, columnWidth: contentWidth, secondary: secondary, rawTheme: theme, subId: sub?.id)
                  self.winstonData?.postDimensionsForcedNormal = getPostDimensions(post: self, winstonData: self.winstonData, columnWidth: contentWidth, secondary: secondary, rawTheme: theme, compact: false)
                }
              }
            }
          }
        }
      default:
        break
      }
      
      self.winstonData?.extractedMedia = extractedMedia
      self.winstonData?.extractedMediaForcedNormal = extractedMediaForcedNormal
      
      
      self.winstonData?.postDimensions = getPostDimensions(post: self, winstonData: self.winstonData, columnWidth: contentWidth, secondary: secondary, rawTheme: theme, subId: sub?.id)
      self.winstonData?.postDimensionsForcedNormal = getPostDimensions(post: self, winstonData: self.winstonData, columnWidth: contentWidth, secondary: secondary, rawTheme: theme, compact: false)
      
      self.winstonData?.titleAttr = createTitleTagsAttrString(titleTheme: theme.postLinks.theme.titleText, postData: data, textColor: theme.postLinks.theme.titleText.color.uiColor())
      
      if let sub {
        self.winstonData?.subreddit = sub
      } else {
        self.winstonData?._strongSubreddit = Subreddit(id: data.subreddit)
      }
      
      if fetchAvatar {
        Task(priority: .background) {
          await RedditAPI.shared.updatePostsWithAvatar(posts: [self], avatarSize: theme.postLinks.theme.badge.avatar.size)
        }
      }
    }
  }
  
  static func extractFlairData(data: PostData, checkDefaultsForColor: Bool = false) -> PrependTag? {
    
    if let flair = data.link_flair_text, let cleansed = flairWithoutEmojis(str: flair), !cleansed.joined().isEmpty {
      let hasBackground = data.link_flair_background_color != nil && !data.link_flair_background_color!.isEmpty
      let textColor = hasBackground && data.link_flair_text_color != nil ? (data.link_flair_text_color! == "light" ? "FFFFFF" : "000000") : "000000"
      let bgColor = hasBackground ? data.link_flair_background_color! : "D5D7D9"
      
      return PrependTag(label: flair, bgColor: UIColor(hex: bgColor), textColor: UIColor(hex: textColor))
    }
    return nil
    //
    //        if bgColor == "D5D7D9" && checkDefaultsForColor {
    //          if let subId = data.subreddit_id, let flairText = data.link_flair_text {
    //            let context = PersistenceController.shared.container.newBackgroundContext()
    //            let fetchRequest = NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
    //            fetchRequest.predicate = NSPredicate(format: "subreddit_id == %@ && text == %@ && type == 'flair'", subId, flairText)
    //
    //            let prevSubFlairs = (context.performAndWait { try? context.fetch(fetchRequest) }) ?? []
    //            if let prevFlair = prevSubFlairs.first {
    //              context.performAndWait {
    //                bgColor = prevFlair.background_color ?? bgColor
    //                textColor = prevFlair.text_color ?? textColor
    //              }
    //            }
    //          }
    //        }
    //
    //        return FilterData(text: cleansed.joined(separator: " "), text_color: textColor, background_color: bgColor)
    //      }
    //
    //      return nil
  }
  
  static func initMultiple(datas: [T], sub: Subreddit? = nil, contentWidth: CGFloat = 0) -> [Post] {
    let context = PersistenceController.shared.container.newBackgroundContext()
    let fetchRequest = NSFetchRequest<SeenPost>(entityName: "SeenPost")
    let theme = InMemoryTheme.shared.currentTheme
    
    if let results = (context.performAndWait { try? context.fetch(fetchRequest) }) {
      
      let posts = Array(datas.enumerated()).concurrentMap { i, data in
        let isSeen = context.performAndWait { results.contains(where: { $0.postID == data.id }) }
        let priorityIMap: [Int:ImageRequest.Priority] = [
          4: .veryHigh,
          9: .high,
          14: .normal,
          19: .low
        ]
        let priority = i > 19 ? .veryLow : priorityIMap[priorityIMap.keys.first { $0 > i } ?? 19]!
        let newPost = Post(data: data, sub: sub, contentWidth: contentWidth, imgPriority: i > 7 ? .veryLow : priority, theme: theme, fetchAvatar: false)
        newPost.data?.winstonSeen = isSeen
        
        if (isSeen) {
          Task {
            await context.perform {
              let foundPost =  results.first(where: { $0.postID == data.id })
              newPost.winstonData?.seenCommentsCount = Int(foundPost?.numComments ?? 0)
              newPost.winstonData?.seenComments = foundPost?.seenComments
            }
          }
        }
        
        return newPost
      }
      
      let repostsAvatars = posts.compactMap { post in
        if case .repost(let repost) = post.winstonData?.extractedMedia {
          return repost
        }
        return nil
      }
      
      Task(priority: .background) { await RedditAPI.shared.updatePostsWithAvatar(posts: repostsAvatars, avatarSize: InMemoryTheme.shared.currentTheme.postLinks.theme.badge.avatar.size) }
      Task(priority: .background) { await RedditAPI.shared.updatePostsWithAvatar(posts: posts, avatarSize: InMemoryTheme.shared.currentTheme.postLinks.theme.badge.avatar.size) }
      
      return posts
    }
    
    return []
  }
  
  //  static func saveFlairsFromPosts(sub: Subreddit, posts: [Post]) {
  //    let context = PersistenceController.shared.container.newBackgroundContext()
  //    let fetchRequest = NSFetchRequest<CachedFilter>(entityName: "CachedFilter")
  //    fetchRequest.predicate = NSPredicate(format: "subreddit_id == %@", sub.id)
  //
  //    var prevSubFlairs = (context.performAndWait { try? context.fetch(fetchRequest) }) ?? []
  //
  //    context.performAndWait {
  //      posts.forEach { post in
  //        if let data = post.data, let flairText = data.link_flair_text {
  //          guard let flairData = Post.extractFlairData(data: data) else { return }
  //
  //          if let prev = prevSubFlairs.first(where: { $0.text == flairText }) {
  //            prev.occurences = prev.occurences + 1
  //
  //            if flairData.background_color != "D5D7D9" && flairData.background_color != prev.background_color {
  //              prev.background_color = flairData.background_color
  //              prev.text_color = flairData.text_color
  //            }
  //          } else {
  //            let newFilter = CachedFilter(context: context)
  //
  //            newFilter.subreddit_id = sub.id
  //            newFilter.type = "flair"
  //            newFilter.text = flairData.text
  //            newFilter.text_color = flairData.text_color
  //            newFilter.background_color = flairData.background_color
  //            newFilter.occurences = 1
  //
  //            prevSubFlairs.append(newFilter)
  //          }
  //        }
  //      }
  //
  //      try? context.save()
  //
  //      let flairFilters = prevSubFlairs.map({ FilterData.from($0) })
  //      DispatchQueue.main.async {
  //        withAnimation {
  //          sub.winstonData?.flairs = flairFilters
  //        }
  //      }
  //    }
  //  }
  
  func loadStreamableMedia(streamable: StreamableExtracted) async -> SharedVideo? {
    let response = await AF.request(
      "https://api.streamable.com/videos/\(streamable.shortCode)"
    ).serializingDecodable(StreamableAPIResponse.self).response
    
    switch response.result {
    case .success(let data):
      if let mp4 = data.files?.mp4Mobile ?? data.files?.mp4 {
        if let videoURL = URL(string: mp4.url) {
          let size =  CGSize(width: mp4.width, height: mp4.height)
          return SharedVideo.get(url: videoURL, size: size)
        }
      }
    case .failure:
      return nil
    }
    
    return nil
  }
  
  func toggleSeen(_ seen: Bool? = nil, optimistic: Bool = false) async -> Void {
    let context = PersistenceController.shared.primaryBGContext
    if (self.data?.winstonSeen ?? false) == seen { return }
    if optimistic {
      let prev = self.data?.winstonSeen ?? false
      let new = seen == nil ? !prev : seen
      DispatchQueue.main.async {
        withAnimation {
          if prev != new { self.data?.winstonSeen = new }
        }
      }
    }
    let fetchRequest = NSFetchRequest<SeenPost>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) }) {
      await context.perform(schedule: .enqueued) {
        let foundPost = results.first(where: { obj in obj.postID == self.id })
        
        if let foundPost = foundPost {
          if seen == nil || seen == false {
            context.delete(foundPost)
            if !optimistic {
              self.data?.winstonSeen = false
            }
          }
        } else if seen == nil || seen == true {
          let newSeenPost = SeenPost(context: context)
          newSeenPost.postID = self.id
          try? context.save()
          if !optimistic {
            DispatchQueue.main.async {
              withAnimation {
                self.data?.winstonSeen = true
              }
            }
          }
        }
      }
    }
  }
  
  func toggleFilterSubreddit(_ subreddit: String) async -> Void {
    var filteredSubreddits = Defaults[.filteredSubreddits]
    
    if let index = filteredSubreddits.firstIndex(of: subreddit) {
      // Subreddit exists in the array, remove it
      filteredSubreddits.remove(at: index)
    } else {
      // Subreddit doesn't exist in the array, add it
      filteredSubreddits.append(subreddit)
    }
    
    // Update the Defaults value with the modified array
    Defaults[.filteredSubreddits] = filteredSubreddits
  }
  
  func saveCommentsCount(numComments: Int) async -> Void {
    let context = PersistenceController.shared.primaryBGContext
    
    let fetchRequest = NSFetchRequest<SeenPost>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) }) {
      await context.perform(schedule: .enqueued) {
        let foundPost = results.first(where: { obj in obj.postID == self.id })
        
        if let seenPost = foundPost {
          seenPost.numComments = Int32(numComments)
          try? context.save()
          
          DispatchQueue.main.async {
            withAnimation {
              self.winstonData?.seenCommentsCount = numComments
            }
          }
        } else {
          let newSeenPost = SeenPost(context: context)
          newSeenPost.postID = self.id
          newSeenPost.numComments = Int32(numComments)
          try? context.save()
          
          DispatchQueue.main.async {
            withAnimation {
              self.data?.winstonSeen = true
              self.winstonData?.seenCommentsCount = numComments
            }
          }
        }
      }
    }
  }
  
  func saveSeenComments(comments: ListingData<CommentData>?) async -> Void {
    let context = PersistenceController.shared.primaryBGContext
    let newComments = self.getCommentIds(comments: comments)
    
    let fetchRequest = NSFetchRequest<SeenPost>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) }) {
      await context.perform(schedule: .enqueued) {
        let foundPost = results.first(where: { obj in obj.postID == self.id })
        
        if let seenPost = foundPost {
          var seenComments = seenPost.seenComments ?? ""
          newComments.forEach { id in
            if (!seenComments.contains(id)) {
              seenComments += "\(seenComments.isEmpty ? "" : ",")\(id)"
            }
          }
          
          let finalSeen = seenComments
          seenPost.seenComments = finalSeen
          try? context.save()
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
              self.winstonData?.seenComments = finalSeen
            }
          }
        }
      }
    }
  }
  
  func saveMoreComments(comments: [Comment]) async -> Void {
    let context = PersistenceController.shared.primaryBGContext
    
    let fetchRequest = NSFetchRequest<SeenPost>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) }) {
      await context.perform(schedule: .enqueued) {
        let foundPost = results.first(where: { obj in obj.postID == self.id })
        
        if let seenPost = foundPost {
          var seenComments = seenPost.seenComments ?? ""
          let newComments: [String] = comments.map { $0.data?.id ?? "" }
          
          newComments.forEach { id in
            if (!seenComments.contains(id)) {
              seenComments += "\(seenComments.isEmpty ? "" : ",")\(id)"
            }
          }
          
          let finalSeen = seenComments
          seenPost.seenComments = finalSeen
          try? context.save()
          
          DispatchQueue.main.async {
            withAnimation {
              self.winstonData?.seenComments = finalSeen
            }
          }
        }
      }
    }
  }
  
  
  func getCommentIds(comments: ListingData<CommentData>?) -> Array<String> {
    var ids = Array<String>()
    
    if let children = comments?.children {
      for i in 0...children.count - 1 {
        let child = children[i]
        
        if (child.kind == "more") { continue }
        
        if let commentId = child.data?.id {
          ids.append(commentId)
        }
        
        if let replies = child.data?.replies  {
          switch replies {
          case .first(_):
            break
          case .second(let actualData):
            ids += getCommentIds(comments: actualData.data)
          }
        }
      }
    }
    
    return ids
  }
  
  func reply(_ text: String, updateComments: (() -> ())? = nil) async -> Bool {
    if let fullname = data?.name {
      let result = await RedditAPI.shared.newReply(text, fullname) ?? false
      if result {
        if let updateComments = updateComments {
          await MainActor.run {
            withAnimation {
              updateComments()
            }
          }
        }
        //        if let data = data {
        //          let newComment = CommentData(
        //            subreddit_id: data.subreddit_id,
        //            subreddit: data.subreddit,
        //            likes: true,
        //            saved: false,
        //            id: UUID().uuidString,
        //            archived: false,
        //            count: 0,
        //            author: RedditAPI.shared.me?.data?.name ?? "",
        //            created_utc: nil,
        //            send_replies: nil,
        //            parent_id: id,
        //            score: nil,
        //            author_fullname: "t2_\(redditAPI.me?.data?.id ?? "")",
        //            approved_by: nil,
        //            mod_note: nil,
        //            collapsed: nil,
        //            body: text,
        //            top_awarded_type: nil,
        //            name: nil,
        //            downs: 0,
        //            children: nil,
        //            body_html: nil,
        //            created: Double(Int(Date().timeIntervalSince1970)),
        //            link_id: data.id,
        //            link_title: data.title,
        //            subreddit_name_prefixed: data.subreddit_name_prefixed,
        //            depth: 0,
        //            author_flair_background_color: nil,
        //            collapsed_because_crowd_control: nil,
        //            mod_reports: nil,
        //            num_reports: nil,
        //            ups: 1
        //          )
        //          await MainActor.run {
        //            withAnimation {
        //              childrenWinston.append(Comment(data: newComment))
        //            }
        //          }
        //        }
      }
      return result
    }
    return false
  }
  
  func refreshPost(commentID: String? = nil, sort: CommentSortOption = .confidence, after: String? = nil, subreddit: String? = nil, full: Bool = true, subId: String? = nil) async -> ([Comment]?, String?)? {
    if let subreddit = data?.subreddit ?? subreddit, let response = await RedditAPI.shared.fetchPost(subreddit: subreddit, postID: id, commentID: commentID, sort: sort) {
      if response.count >= 2 {
        if let post = response[0] {
          switch post {
          case .first(let actualData):
            if full {
              await MainActor.run {
                let newData = actualData.data?.children?[0].data
                self.data = newData
                setupWinstonData(data: newData, secondary: false, theme: InMemoryTheme.shared.currentTheme)
              }
            }
          case .second(_):
            break
          }
        }
        
        if let comments = response[1] {
          switch comments {
          case .first(_):
            return nil
          case .second(let actualData):
            if let data = actualData.data, let children = data.children {
              await saveSeenComments(comments: data)
              
              let dataArr = children.compactMap { $0 }
              let comments = Comment.initMultiple(datas: dataArr)
              return (comments, data.after)
            }
          }
        }
      }
    }
    return nil
  }
  
  func saveToggle() async -> Bool {
    if let data = data {
      let prev = data.saved
      await MainActor.run {
        withAnimation {
          self.data?.saved = !prev
        }
      }
      let success = await RedditAPI.shared.save(!prev, id: data.name)
      if !(success ?? false) {
        await MainActor.run {
          withAnimation {
            self.data?.saved = prev
          }
        }
        return false
      }
      return true
    }
    return false
  }
  
  func vote(_ action: RedditAPI.VoteAction) async -> Bool? {
    let oldLikes = data?.likes
    let oldUps = data?.ups ?? 0
    var newAction = action
    newAction = action.boolVersion() == oldLikes ? .none : action
    await MainActor.run { [newAction] in
      withAnimation(.spring()) {
        data?.likes = newAction.boolVersion()
        data?.ups = oldUps + (action.boolVersion() == oldLikes ? oldLikes == nil ? 0 : -(Int(action.rawValue) ?? 0) : (Int(action.rawValue) ?? 1) * (oldLikes == nil ? 1 : 2))
      }
    }
    let result = await RedditAPI.shared.vote(newAction, id: "\(typePrefix ?? "")\(id)")
    if result == nil || !result! {
      await MainActor.run {
        withAnimation(.spring()) {
          data?.likes = oldLikes
          data?.ups = oldUps
        }
      }
    }
    return result
  }
  
  func hide(_ hide: Bool) async -> () {
    if data?.winstonHidden == hide { return }
    await MainActor.run {
      withAnimation {
        data?.winstonHidden = true
      }
    }
    if let name = data?.name {
      await RedditAPI.shared.hidePost(hide, fullnames: [name])
    }
  }
}



