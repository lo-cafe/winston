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

typealias Post = GenericRedditEntity<PostData, PostWinstonData>

extension Post {
  static var prefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared, destination: .memoryCache, maxConcurrentRequestCount: 5)
  static var prefix = "t3"
  
  convenience init(data: T, api: RedditAPI, fetchSub: Bool = false, contentWidth: Double = UIScreen.screenWidth, secondary: Bool = false, imgPriority: ImageRequest.Priority = .low) {
    self.init(data: data, api: api, typePrefix: "\(Post.prefix)_")
    self.winstonData = PostWinstonData()
    self.winstonData?.permaURL = URL(string: "https://reddit.com\(data.permalink.escape.urlEncoded)")
    
    if fetchSub {
      self.winstonData?.subreddit = Subreddit(id: data.subreddit, api: RedditAPI.shared)
    }
    
    Task (priority: .high) {
      await self.initMedia(data: data, contentWidth: contentWidth, secondary: secondary)
      self.winstonData?.loaded = true
    }

    if let body = self.data?.selftext {
      Caches.postsAttrStr.addKeyValue(key: data.id, data: {
        let theme = Defaults[.themesPresets].first(where: { $0.id == Defaults[.selectedThemeID] }) ?? defaultTheme
        return stringToAttr(body, fontSize: theme.posts.bodyText.size)
      })
    }
    
    if let sub = self.data?.subreddit, Defaults[.subredditIcons][sub] == nil {
      // Save empty value to prevent multiple fetches on the same subreddit icon
      Defaults[.subredditIcons][id] = [:]
      
      Task {
        // Asynchronously fetch icon
        if let data = (await RedditAPI.shared.fetchSub(sub))?.data  {
          if (data.community_icon != nil && data.community_icon!.count > 0) || (data.icon_img != nil && data.icon_img!.count > 0),
             let displayName = data.display_name {
            Defaults[.subredditIcons][displayName] = [ "community_icon" : data.community_icon, "icon_img" : data.icon_img ]
          }
        }
      }
    } else {
      let sub = self.data?.subreddit ?? "NULL"
    }
    
  }
  
  func waitForMediaToLoad() async {
    while ((self.winstonData?.loaded ?? false) != true) {
      continue;
    }
    
    return
  }
  
  func initMedia(data: T,  contentWidth: Double, secondary: Bool) async {
    let extractedMedia = await mediaExtractor(contentWidth: contentWidth, data)
    
    DispatchQueue.main.async {
      self.winstonData?.extractedMedia = extractedMedia
      self.winstonData?.postDimensions = getPostDimensions(post: self, columnWidth: contentWidth, secondary: secondary)
      
      let compact = Defaults[.compactMode]
      switch extractedMedia {
      case .image(let url):
        let processors: [ImageProcessing] = contentWidth == 0 ? [] : [.resize(width: compact ? scaledCompactModeThumbSize() : contentWidth)]
        self.winstonData?.mediaImageRequest = [ImageRequest(url: url.url, processors: processors)]
      case .gallery(let imgs):
        let halfWidthProcessor: [ImageProcessing] = contentWidth == 0 ? [] : [.resize(width: compact ? scaledCompactModeThumbSize() : ((contentWidth - 8) / 2))]
        let fullWidthProcessor: [ImageProcessing] = contentWidth == 0 ? [] : [.resize(width: compact ? scaledCompactModeThumbSize() : contentWidth)]
        var requests: [ImageRequest] = []
        if imgs.count >= 1 { requests.append(ImageRequest(url: imgs[0].url, processors: halfWidthProcessor)) }
        if imgs.count >= 2 { requests.append(ImageRequest(url: imgs[1].url, processors: halfWidthProcessor)) }
        if imgs.count >= 3 { requests.append(ImageRequest(url: imgs[2].url, processors: imgs.count > 3 ? halfWidthProcessor : fullWidthProcessor)) }
        requests += imgs.dropFirst(3).map { ImageRequest(url: $0.url, priority: .low) }
        self.winstonData?.mediaImageRequest = requests
      case .link(let url):
        Caches.postsPreviewModels.addKeyValue(key: url.absoluteString, data: { PreviewModel(url) })
        break
      default:
        break
      }
    }
  }
  
  convenience init(id: String, api: RedditAPI) {
    self.init(id: id, api: api, typePrefix: "\(Post.prefix)_")
    
    let context = PersistenceController.shared.container.newBackgroundContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
    fetchRequest.predicate = NSPredicate(format: "postID == %@", id)
    if let seenPost = (context.performAndWait { (try? context.fetch(fetchRequest) as? [SeenPost])?.first }) {
      context.performAndWait {
        self.data?.winstonSeen = true
        self.data?.winstonSeenCommentCount = Int(seenPost.numComments)
        self.data?.winstonSeenComments = seenPost.seenComments
      }
    }
  }
  
  static func initMultiple(datas: [T], api: RedditAPI, fetchSubs: Bool = false, contentWidth: CGFloat = 0) -> [Post] {
    let context = PersistenceController.shared.container.newBackgroundContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
      
    if let results = (context.performAndWait { try? context.fetch(fetchRequest) as? [SeenPost] }) {
      let posts = Array(datas.enumerated()).map { i, data in
        return context.performAndWait {
          let isSeen = results.contains(where: { $0.postID == data.id })
          let priorityIMap: [Int:ImageRequest.Priority] = [
            4: .veryHigh,
            9: .high,
            14: .normal,
            19: .low
          ]
          let priority = i > 19 ? .veryLow : priorityIMap[priorityIMap.keys.first { $0 > i } ?? 19]!
          let newPost = Post.init(data: data, api: api, fetchSub: fetchSubs, contentWidth: contentWidth, imgPriority: i > 7 ? .veryLow : priority)
          newPost.data?.winstonSeen = isSeen
          
          if (isSeen) {
            let foundPost = results.first(where: { $0.postID == data.id })
            newPost.data?.winstonSeenCommentCount = Int(foundPost?.numComments ?? 0)
            newPost.data?.winstonSeenComments = foundPost?.seenComments
          }
          
          return newPost
        }
      }
      
      let imgRequests = posts.reduce(into: []) { prev, curr in
        prev = prev + (curr.winstonData?.mediaImageRequest ?? [])
      }
      
      Post.prefetcher.startPrefetching(with: imgRequests)
      return posts
    }
    return []
  }
  
  func toggleSeen(_ seen: Bool? = nil, optimistic: Bool = false) async -> Void {
    let context = PersistenceController.shared.container.viewContext
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
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) as? [SeenPost] }) {
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
  
  func saveCommentCount(numComments: Int) async -> Void {
    let context = PersistenceController.shared.container.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) as? [SeenPost] }) {
      await context.perform(schedule: .enqueued) {
        let foundPost = results.first(where: { obj in obj.postID == self.id })
        
        if let seenPost = foundPost {
          seenPost.numComments = Int32(numComments)
          try? context.save()
          
          DispatchQueue.main.async {
            withAnimation {
              self.data?.winstonSeenCommentCount = numComments
            }
          }
        }
      }
    }
  }
  
  func saveSeenComments(comments: ListingData<CommentData>?) async -> Void {
    let context = PersistenceController.shared.container.viewContext
    let newComments = self.getCommentIds(comments: comments)

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) as? [SeenPost] }) {
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
              self.data?.winstonSeenComments = finalSeen
            }
          }
        }
      }
    }
  }
  
  func saveMoreComments(comments: [Comment]) async -> Void {
    let context = PersistenceController.shared.container.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeenPost")
    if let results = (await context.perform(schedule: .enqueued) { try? context.fetch(fetchRequest) as? [SeenPost] }) {
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
              self.data?.winstonSeenComments = finalSeen
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
        //              childrenWinston.data.append(Comment(data: newComment, api: self.redditAPI))
        //            }
        //          }
        //        }
      }
      return result
    }
    return false
  }
  
  func refreshPost(commentID: String? = nil, sort: CommentSortOption = .confidence, after: String? = nil, subreddit: String? = nil, full: Bool = true) async -> ([Comment]?, String?)? {
    if let subreddit = data?.subreddit ?? subreddit, let response = await RedditAPI.shared.fetchPost(subreddit: subreddit, postID: id, commentID: commentID, sort: sort) {
      if let post = response[0] {
        switch post {
        case .first(let actualData):
          if let numComments = actualData.data?.children?[0].data?.num_comments {
            await saveCommentCount(numComments: numComments)
          }
          
          if full {
            await MainActor.run {
              let newData = actualData.data?.children?[0].data
              self.data = newData
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
          if let data = actualData.data {
            await saveSeenComments(comments: data)

            if let dataArr = data.children?.compactMap({ $0 }) {
              let comments = Comment.initMultiple(datas: dataArr, api: RedditAPI.shared);
              return ( comments, data.after )
            }
            return nil
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
  
  func vote(action: RedditAPI.VoteAction) async -> Bool? {
    let oldLikes = data?.likes
    let oldUps = data?.ups ?? 0
    var newAction = action
    newAction = action.boolVersion() == oldLikes ? .none : action
    await MainActor.run { [newAction] in
      data?.likes = newAction.boolVersion()
      data?.ups = oldUps + (action.boolVersion() == oldLikes ? oldLikes == nil ? 0 : -action.rawValue : action.rawValue * (oldLikes == nil ? 1 : 2))
    }
    let result = await RedditAPI.shared.vote(newAction, id: "\(typePrefix ?? "")\(id)")
    if result == nil || !result! {
      await MainActor.run {
        data?.likes = oldLikes
        data?.ups = oldUps
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

class PostWinstonData: Hashable {
  static func == (lhs: PostWinstonData, rhs: PostWinstonData) -> Bool { lhs.postDimensions == rhs.postDimensions }
  
  var permaURL: URL? = nil
  var extractedMedia: MediaExtractedType? = nil
  var subreddit: Subreddit?
  var mediaImageRequest: [ImageRequest] = []
  var postDimensions: PostDimensions?
  var loaded = false
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(permaURL)
    hasher.combine(extractedMedia)
    hasher.combine(subreddit)
    hasher.combine(postDimensions)
  }
}

struct PostData: GenericRedditEntityDataType {
  let subreddit: String
  let selftext: String
  var author_fullname: String? = nil
  var saved: Bool
  let gilded: Int
  let clicked: Bool
  let title: String
  let subreddit_name_prefixed: String
  let hidden: Bool
  var ups: Int
  var downs: Int
  let hide_score: Bool
  var post_hint: String? = nil
  let name: String
  let quarantine: Bool
  var link_flair_text_color: String? = nil
  let upvote_ratio: Double
  let subreddit_type: String
  let total_awards_received: Int
  let is_self: Bool
  let created: Double
  let domain: String
  let allow_live_comments: Bool
  var selftext_html: String? = nil
  let id: String
  let is_robot_indexable: Bool
  let author: String
  let num_comments: Int
  let send_replies: Bool
  var whitelist_status: String? = nil
  let contest_mode: Bool
  let permalink: String
  let url: String
  let subreddit_subscribers: Int
  var created_utc: Double? = nil
  let num_crossposts: Int
  var is_video: Bool? = nil
  var is_gallery: Bool? = nil
  var gallery_data: GalleryData? = nil
  var crosspost_parent_list: [PostData]? = nil
  var media_metadata: [String:MediaMetadataItem?]? = nil
  // Optional properties
  var wls: Int? = nil
  var pwls: Int? = nil
  var link_flair_text: String? = nil
  var thumbnail: String? = nil
  //  let edited: Edited?
  var link_flair_template_id: String? = nil
  var author_flair_text: String? = nil
  var media: Media? = nil
  var approved_at_utc: Int? = nil
  var mod_reason_title: String? = nil
  var top_awarded_type: String? = nil
  var author_flair_background_color: String? = nil
  var approved_by: String? = nil
  var is_created_from_ads_ui: Bool? = nil
  var author_premium: Bool? = nil
  var author_flair_css_class: String? = nil
  var gildings: [String: Int]? = nil
  var content_categories: [String]? = nil
  var mod_note: String? = nil
  var link_flair_type: String? = nil
  var removed_by_category: String? = nil
  var banned_by: String? = nil
  var author_flair_type: String? = nil
  var likes: Bool? = nil
  var stickied: Bool? = nil
  var suggested_sort: String? = nil
  var banned_at_utc: String? = nil
  var view_count: String? = nil
  var archived: Bool? = nil
  var no_follow: Bool? = nil
  var is_crosspostable: Bool? = nil
  var pinned: Bool? = nil
  var over_18: Bool? = nil
  //  let all_awardings: [Awarding]?
  var awarders: [String]? = nil
  var media_only: Bool? = nil
  var can_gild: Bool? = nil
  var spoiler: Bool? = nil
  var locked: Bool? = nil
  var treatment_tags: [String]? = nil
  var visited: Bool? = nil
  var removed_by: String? = nil
  var num_reports: Int? = nil
  var distinguished: String? = nil
  var subreddit_id: String? = nil
  var author_is_blocked: Bool? = nil
  var mod_reason_by: String? = nil
  var removal_reason: String? = nil
  var link_flair_background_color: String? = nil
  var report_reasons: [String]? = nil
  var discussion_type: String? = nil
  var secure_media: Media? = nil
  var secure_media_embed: SecureMediaEmbed? = nil
  var preview: Preview? = nil
  var winstonSeen: Bool? = nil
  var winstonHidden: Bool? = nil
  var winstonSeenCommentCount: Int? = nil
  var winstonSeenComments: String? = nil
}

struct GalleryData: Codable, Hashable {
  let items: [GalleryDataItem]?
}

struct GalleryDataItem: Codable, Hashable, Identifiable {
  let media_id: String
  let id: Double
}

struct MediaMetadataItem: Codable, Hashable, Identifiable {
  let status: String
  let e: String?
  let m: String?
  let p: [MediaMetadataItemSize]?
  let s: MediaMetadataItemSize?
  let id: String?
}

struct MediaMetadataItemSize: Codable, Hashable {
  let x: Int
  let y: Int
  let u: String?
}

struct PreviewImg: Codable, Hashable {
  let url: String?
  let width: Int?
  let height: Int?
  let id: String?
}

struct PreviewImgCollection: Codable, Hashable {
  let source: PreviewImg?
  let resolutions: [PreviewImg]?
  //  let variants: Oembed?
  let id: String?
}

struct RedditVideoPreview: Codable, Hashable {
  let bitrate_kbps: Double?
  let fallback_url: String?
  let height: Double?
  let width: Double?
  let scrubber_media_url: String?
  let dash_url: String?
  let duration: Double?
  let hls_url: String?
  let is_gif: Bool?
  let transcoding_status: String?
}

struct Preview: Codable, Hashable {
  let images: [PreviewImgCollection]?
  let reddit_video_preview: RedditVideoPreview?
  let enabled: Bool?
}

struct Media: Codable, Hashable {
  let type: String?
  let oembed: Oembed?
  let reddit_video: RedditVideo?
}

struct Oembed: Codable, Hashable {
  let provider_url: String?
  let version: String?
  let title: String?
  let type: String?
  let thumbnail_width: Int?
  let height: Int?
  let width: Int?
  let html: String?
  let author_name: String?
  let provider_name: String?
  let thumbnail_url: String?
  let thumbnail_height: Int?
  let author_url: String?
}

struct RedditVideo: Codable, Hashable {
  let bitrate_kbps: Int?
  let fallback_url: String?
  let has_audio: Bool?
  let height: Int?
  let width: Int?
  let scrubber_media_url: String?
  let dash_url: String?
  let duration: Int?
  let hls_url: String?
  let is_gif: Bool?
  let transcoding_status: String?
}

struct SecureMediaEmbed: Codable, Hashable {
  let content: String?
  let width: Int?
  let scrolling: Bool?
  let media_domain_url: String?
  let height: Int?
}

struct Awarding: Codable, Hashable {
  let id: String
  let name: String
  let description: String
  let coin_price: Int
  let coin_reward: Int
  let icon_url: String
  let is_enabled: Bool
  let count: Int
  
  // Optional properties
  let days_of_premium: Int?
  let award_sub_type: String?
  let days_of_drip_extension: Int?
  let icon_height: Int?
  let icon_width: Int?
  let is_new: Bool?
  let subreddit_coin_reward: Int?
  let tier_by_required_awardings: [String: Int]?
  let award_type: String?
  let awardings_required_to_grant_benefits: Int?
  let start_date: Double?
  let end_date: Double?
  let static_icon_height: Int?
  let static_icon_url: String?
  let static_icon_width: Int?
  let subreddit_id: String?
}

enum Edited: Codable {
  case bool(Bool)
  case double(Double)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let boolValue = try? container.decode(Bool.self) {
      self = .bool(boolValue)
    } else if let doubleValue = try? container.decode(Double.self) {
      self = .double(doubleValue)
    } else {
      throw DecodingError.typeMismatch(Edited.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected value of type Bool or Double"))
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .bool(let boolValue):
      try container.encode(boolValue)
    case .double(let doubleValue):
      try container.encode(doubleValue)
    }
  }
}
