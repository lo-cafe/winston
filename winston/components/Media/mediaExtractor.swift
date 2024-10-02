//
//  mediaExtractor.swift
//  winston
//
//  Created by Igor Marcossi on 21/08/23.
//

import Foundation
import SwiftUI
import NukeUI
import Nuke
import YouTubePlayerKit
import Alamofire

struct ImgExtracted: Equatable, Identifiable {
  static func == (lhs: ImgExtracted, rhs: ImgExtracted) -> Bool {
    lhs.id == rhs.id && lhs.size == rhs.size
  }
  
  let url: URL
  let size: CGSize
  let request: ImageRequest
  var id: String { self.url.absoluteString }
}

struct YTMediaExtracted: Equatable, Identifiable {
  static func == (lhs: YTMediaExtracted, rhs: YTMediaExtracted) -> Bool {
    lhs.id == rhs.id
  }
  
  let videoID: String
  let size: CGSize
  let thumbnailURL: URL
  let thumbnailRequest: ImageRequest
  let player: YouTubePlayer
  let author: String
  let authorURL: URL
  var id: String { self.videoID }
}

struct EntityExtracted<T: GenericRedditEntityDataType, B: Hashable>: Equatable {
  static func == (lhs: EntityExtracted, rhs: EntityExtracted) -> Bool {
    lhs.entity == rhs.entity
  }
  var subredditID: String? = nil
  var postID: String? = nil
  var commentID: String? = nil
  var userID: String? = nil
  let entity: GenericRedditEntity<T, B>
}

struct StreamableExtracted: Equatable {
  static func == (lhs: StreamableExtracted, rhs: StreamableExtracted) -> Bool {
    lhs.shortCode == rhs.shortCode
  }
  
  let shortCode: String
  init(url: String) {
    self.shortCode = String(url[url.index(url.lastIndex(of: "/") ?? url.startIndex, offsetBy: 1)...])
  }
}

struct StreamableCached: Equatable {
  static func == (lhs: StreamableCached, rhs: StreamableCached) -> Bool {
    lhs.url == rhs.url && lhs.size == rhs.size
  }
  
  let url: URL
  let size: CGSize
  
  init(url: URL, size: CGSize) {
    self.url = url
    self.size = size
  }
}

struct RedgifsExtracted: Equatable {
  static func == (lhs: RedgifsExtracted, rhs: RedgifsExtracted) -> Bool {
      lhs.id == rhs.id
  }
  
  let id: String
  
  init(id: String) {
    self.id = id
  }
}

struct RedgifsCached: Equatable {
  static func == (lhs: RedgifsCached, rhs: RedgifsCached) -> Bool {
    lhs.url == rhs.url && lhs.size == rhs.size
  }
  
  let url: URL
  let size: CGSize
  
  init(url: URL, size: CGSize) {
    self.url = url
    self.size = size
  }
}

enum RedgifsError: Error {
  case tokenNonExistent
}

class RedgifsClient {
  static let shared = RedgifsClient()
  
  private var token: String?
  private var tokenExpiry: Date?
  
  private init() {}
  
  func refreshToken() async throws {
    let token: String = try await RedgifsClient.getToken()
    self.token = token
    tokenExpiry = await RedgifsClient.getTokenExpiry(token: token)
  }
  
  func getToken() async throws -> String {
    if token == nil {
      try await refreshToken()
    } else if let tokenExpiry = tokenExpiry, Date.now > tokenExpiry {
      try await refreshToken()
    }
    
    guard let token else { throw RedgifsError.tokenNonExistent }
    
    return token
  }
  
  private struct JWTData: Decodable {
    let expiry: Date
    
    enum CodingKeys: String, CodingKey {
      case expiry = "exp"
    }
  }
  
  private struct TokenResponse: Decodable {
    let token: String
    let expiry: Date?
  }
  
  static func getTokenExpiry(token: String) async -> Date? {
    // Get the data part of a JWT, Base64 Decode that into a JSON string, decode that JSON and extract the expiry
    let splitToken = token.components(separatedBy: ".")
    if splitToken.count == 3, let decodedData = Data(base64Encoded: splitToken[1]) {
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .secondsSince1970

      guard let jwtData = try? jsonDecoder.decode(JWTData.self, from: decodedData) else {
        return nil
      }
      
      return jwtData.expiry
    } else {
      return nil
    }
  }
  
  static func getToken() async throws -> String {
    let headers: HTTPHeaders = [.accept("application/json"),.defaultUserAgent,.defaultAcceptEncoding,.defaultAcceptLanguage]
    
    let data = try await AF.request("https://api.redgifs.com/v2/auth/temporary", headers: headers)
      .validate()
      .serializingDecodable(TokenResponse.self)
      .value
    
    return data.token
  }
}

enum MediaExtractedType: Equatable {
  case link(PreviewModel)
  case video(SharedVideo)
  case imgs([ImgExtracted])
  case yt(YTMediaExtracted)
  case streamable(StreamableExtracted)
  case redgifs(RedgifsExtracted)
  case repost(Post)
  case post(EntityExtracted<PostData, PostWinstonData>?)
  case comment(EntityExtracted<CommentData, CommentWinstonData>?)
  case subreddit(EntityExtracted<SubredditData, AnyHashable>?)
  case user(EntityExtracted<UserData, AnyHashable>?)
}

fileprivate func urlComponentsExtractor(data: PostData) -> (URLComponents?, [String]) {
  let actualURL = data.url.hasPrefix("/r/") || data.url.hasPrefix("/u/") ? "https://reddit.com\(data.url)" : data.url
  guard let urlComponents = URLComponents(string: actualURL) else {
    return (nil, [])
  }
  
  let pathComponents = urlComponents.path.components(separatedBy: "/").filter({ !$0.isEmpty })
  
  return (urlComponents, pathComponents)
}

// ORDER MATTERS!
func mediaExtractor(compact: Bool, contentWidth: Double = .screenW, _ data: PostData, theme: WinstonTheme? = nil) -> MediaExtractedType? {
  guard !data.is_self else { return nil }
  
  var urlComponents: URLComponents?
  var pathComponents: [String] = []

  let contentWidth = contentWidth - ((theme?.postLinks.theme.innerPadding.horizontal ?? 0) * 2) - ((theme?.postLinks.theme.outerHPadding ?? 0) * 2)
  
  if let is_gallery = data.is_gallery, is_gallery, let galleryData = data.gallery_data?.items, let metadata = data.media_metadata {
    
    let halfWidth = (contentWidth - ImageMediaPost.gallerySpacing) / 2
    let sizes = [
      1: [0: contentWidth],
      2: [0: halfWidth, 1: halfWidth],
      3: [0: halfWidth, 1: halfWidth, 2: contentWidth]
    ]
    
    let galleryArr = Array(galleryData.enumerated()).compactMap { i, item in
      let id = item.media_id
      if let itemMeta = metadata[String(id)], let extArr = itemMeta?.m?.split(separator: "/"), let size = itemMeta?.s, let imgURL = URL(string: "https://i.redd.it/\(id).\(extArr[extArr.count - 1])") {
        
        var actualWidth = contentWidth
        if let sizeInstructions = sizes[galleryData.count], let mySize = sizeInstructions[i] { actualWidth = mySize } else { actualWidth = halfWidth }
        
        let sizeSimple = compact ? scaledCompactModeThumbSize() : actualWidth
        let processors: [ImageProcessing] = contentWidth == 0 ? [] : [ImageProcessors.Resize(size: .init(width: sizeSimple, height: sizeSimple), unit: .points, contentMode: .aspectFill, crop: false, upscale: true)]
        var userInfo: [ImageRequest.UserInfoKey : Any] = [:]
        if compact && !imgURL.absoluteString.hasSuffix(".gif") {
          userInfo[.thumbnailKey] = ImageRequest.ThumbnailOptions(size: .init(width: scaledCompactModeThumbSize(), height: scaledCompactModeThumbSize()), unit: .points, contentMode: .aspectFill)
        }
        return ImgExtracted(url: imgURL, size: CGSize(width: size.x, height: size.y), request: ImageRequest(url: imgURL, processors: processors + [ImageProcessors.ScaleFixer()], userInfo: userInfo))
      }
      return nil
    }
    return .imgs(galleryArr)
  }
  
  if data.domain.contains("streamable.com") {
    return .streamable(StreamableExtracted(url: data.url))
  }
  
  if data.domain.contains("redgifs.com") {
    (urlComponents, pathComponents) = urlComponentsExtractor(data: data)
    
    if let urlComponents = urlComponents {
      if urlComponents.host == "www.redgifs.com" || urlComponents.host == "v3.redgifs.com", pathComponents.count >= 2, pathComponents[0] == "watch" || pathComponents[0] == "ifr" {
        return .redgifs(RedgifsExtracted(id: pathComponents[1]))
      }
    }
  }
  
  if let videoPreview = data.preview?.reddit_video_preview, let url = videoPreview.hls_url, let videoURL = URL(string: url), let width = videoPreview.width, let height = videoPreview.height  {
    return .video(SharedVideo.get(url: videoURL, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
  }
  
  if let redditVideo = data.media?.reddit_video, let url = redditVideo.hls_url, let videoURL = URL(string: url), let width = redditVideo.width, let height = redditVideo.height {
    return .video(SharedVideo.get(url: videoURL, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
  }
  
  if data.media?.type == "youtube.com", let oembed = data.media?.oembed, let html = oembed.html, let ytID = extractYoutubeIdFromOEmbed(html), let width = oembed.width, let height = oembed.height, let author_name = oembed.author_name, let author_url = oembed.author_url, let authorURL = URL(string: author_url), let thumb = oembed.thumbnail_url, let thumbURL = URL(string: thumb) {
    let thumbReq = ImageRequest(url: thumbURL, processors: [.resize(width: getPostContentWidth(contentWidth: contentWidth, theme: theme))], priority: .normal)
    let size = CGSize(width: CGFloat(width), height: CGFloat(height))
    let newExtracted = YTMediaExtracted(videoID: ytID, size: size, thumbnailURL: thumbURL, thumbnailRequest: thumbReq, player: YouTubePlayer(source: .video(id: ytID)), author: author_name, authorURL: authorURL)
    return .yt(newExtracted)
  }
  
  if let postEmbed = data.crosspost_parent_list?.first {
    return .repost(Post(data: postEmbed, contentWidth: contentWidth, secondary: true, theme: theme))
  }
  
  if IMAGES_FORMATS.contains(where: { data.url.hasSuffix($0) }), let url = rootURL(data.url) {
    var actualWidth = 0
    var actualHeight = 0
    if let images = data.preview?.images, images.count > 0, let image = images[0].source, let width = image.width, let height = image.height {
      actualWidth = width
      actualHeight = height
    }
    
    let size = compact ? scaledCompactModeThumbSize() : contentWidth
    let processors: [ImageProcessing] = contentWidth == 0 ? [] : [ImageProcessors.Resize(size: CGSize(width: size, height: size), unit: .points, contentMode: .aspectFill, crop: false, upscale: true)]
    var userInfo: [ImageRequest.UserInfoKey : Any] = [:]
    if compact && !url.absoluteString.hasSuffix(".gif") {
      userInfo[.thumbnailKey] = ImageRequest.ThumbnailOptions(size: .init(width: scaledCompactModeThumbSize(), height: scaledCompactModeThumbSize()), unit: .points, contentMode: .aspectFill)
    }
    let imgExtracted = ImgExtracted(url: url, size: CGSize(width: actualWidth, height: actualHeight), request: ImageRequest(url: url, processors: processors + [ImageProcessors.ScaleFixer()], userInfo: userInfo))
    return .imgs([imgExtracted])
  }
  
  if let images = data.preview?.images, images.count > 0, let image = images[0].source, let src = image.url?.replacing("/preview.", with: "/i."), !src.contains("external-preview"), let imgURL = rootURL(src.escape), let width = image.width, let height = image.height {
    
    let size = compact ? scaledCompactModeThumbSize() : contentWidth
    let processors: [ImageProcessing] = contentWidth == 0 ? [] : [ImageProcessors.Resize(size: CGSize(width: size, height: size), unit: .points, contentMode: .aspectFill, crop: false, upscale: true)]
    var userInfo: [ImageRequest.UserInfoKey : Any] = [:]
    if compact {
      userInfo[.thumbnailKey] = ImageRequest.ThumbnailOptions(size: .init(width: scaledCompactModeThumbSize(), height: scaledCompactModeThumbSize()), unit: .points, contentMode: .aspectFill)
    }
    let imgExtracted = ImgExtracted(url: imgURL, size: CGSize(width: width, height: height), request: ImageRequest(url: imgURL, processors: processors + [ImageProcessors.ScaleFixer()], userInfo: userInfo))
    return .imgs([imgExtracted])
  }
  
  if VIDEOS_FORMATS.contains(where: { data.url.hasSuffix($0) }), let url = URL(string: data.url) {
    return .video(SharedVideo.get(url: url, size: CGSize(width: 0, height: 0)))
  }

  if urlComponents == nil {
    (urlComponents, pathComponents) = urlComponentsExtractor(data: data)
  }
  
  guard let urlComponents else {
    return nil
  }
  
//  let actualURL = data.url.hasPrefix("/r/") || data.url.hasPrefix("/u/") ? "https://reddit.com\(data.url)" : data.url
//  guard let urlComponents = URLComponents(string: actualURL) else {
//    return nil
//  }
//  
//  let pathComponents = urlComponents.path.components(separatedBy: "/").filter({ !$0.isEmpty })
  
  if urlComponents.host?.hasSuffix("reddit.com") == true || urlComponents.host?.hasSuffix("app.winston.cafe") == true, pathComponents.count > 1 {
    switch pathComponents[0] {
    case "r":
      let subredditName = pathComponents[1]
      if pathComponents.count > 2 && pathComponents[2] == "comments" {
        let postId = pathComponents[3]
        if pathComponents.count >= 6 {
          let commentId = pathComponents[5]
          let comment = Comment(id: commentId, typePrefix: Comment.prefix)
          comment.fetchItself()
          let entityExtracted = EntityExtracted(subredditID: subredditName, postID: postId, commentID: commentId, entity: comment)
          return .comment(entityExtracted)
        }
        let post = Post(id: postId, typePrefix: Post.prefix)
        post.fetchItself()
        let entityExtracted = EntityExtracted(subredditID: subredditName, postID: postId, entity: post)
        return .post(entityExtracted)
//        return .post(id: postId, subreddit: subredditName)
      }
      let sub = Subreddit(id: subredditName)
      Task(priority: .background) {
        await sub.refreshSubreddit()
      }
      let entityExtracted = EntityExtracted(subredditID: subredditName, entity: sub)
      return .subreddit(entityExtracted)
      
    case "user", "u":
      let username = pathComponents[1]
      let user = User(id: username, typePrefix: User.prefix)
      user.fetchItself()
      let entityExtracted = EntityExtracted(userID: username, entity: user)
      return .user(entityExtracted)
//      return .user(username: username)
      
    default:
      if !data.is_self, let linkURL = URL(string: data.url) {
        return .link(PreviewModel(linkURL, compact: compact))
      }
    }
  }
  
  if data.post_hint == "link" || !data.domain.isEmpty, let linkURL = URL(string: data.url) {
    return .link(PreviewModel(linkURL, compact: compact))
  }
  
  return nil
}

private func extractYoutubeIdFromOEmbed(_ text: String) -> String? {
  let pattern = "(?<=www\\.youtube\\.com/embed/)[^?]*"
  let regex = try? NSRegularExpression(pattern: pattern)
  return regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)).map {
    String(text[Range($0.range, in: text)!])
  }
}

struct StreamableAPIParams: Codable {}
          
struct StreamableAPIResponse: Codable {
  let files: StreamableAPIFiles?
}

struct StreamableAPIFiles: Codable {
  let mp4 : StreamableAPIFile?
  let mp4Mobile:  StreamableAPIFile?

  enum CodingKeys : String, CodingKey {
    case mp4 = "mp4"
    case mp4Mobile = "mp4-mobile"
  }
}

struct StreamableAPIFile: Codable {
  let url: String
  let width: Int
  let height: Int
}

struct RedgifsResponse: Decodable {
  let created: Date?
  let width: Int?
  let height: Int?
  let username: String
  let videoURL: String
  
  enum OuterKeys: String, CodingKey {
    case gif
  }
  
  enum CodingKeys: String, CodingKey {
    case created = "createDate"
    case width, height
    case username = "userName"
    case URLs = "urls"
  }
  
  enum URLCodingKeys: String, CodingKey {
    case thumbnail
    case videoThumbnail = "vthumbnail"
    case standardDefinition = "sd"
    case highDefinition = "hd"
    case poster
  }
  
  init(from decoder: any Decoder) throws {
    let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
    
    let container = try outerContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .gif)
    
    if let decodedDate = try? container.decode(Int.self, forKey: .created) {
      created = Date(timeIntervalSince1970: Double(decodedDate))
    } else {
      created = nil
    }
    width = try? container.decode(Int.self, forKey: .width)
    height = try? container.decode(Int.self, forKey: .height)
    username = try container.decode(String.self, forKey: .username)
    
    let imageContainer = try container.nestedContainer(
      keyedBy: URLCodingKeys.self,
      forKey: .URLs
    )
    
    // Logic here can be alternated between SD and HD video based on metrics or user prefs
    videoURL = try imageContainer.decode(String.self, forKey: .highDefinition)
  }
}
