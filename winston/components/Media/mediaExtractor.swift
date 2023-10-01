//
//  mediaExtractor.swift
//  winston
//
//  Created by Igor Marcossi on 21/08/23.
//

import Foundation
import SwiftUI
import NukeUI
import YouTubePlayerKit

struct MediaExtracted: Hashable, Equatable, Identifiable {
  let url: URL
  let size: CGSize
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

enum MediaExtractedType: Hashable, Equatable {
  case image(MediaExtracted)
  case video(MediaExtracted)
  case gallery([MediaExtracted])
  case youtube(String, CGSize)
  case link(URL)
  case repost(Post)
  case post(id: String, subreddit: String)
  case comment(id: String, postID: String, subreddit: String)
  case subreddit(name: String)
  case user(username: String)
}

// ORDER MATTERS!
func mediaExtractor(contentWidth: Double = UIScreen.screenWidth, _ data: PostData) -> MediaExtractedType? {
  guard !data.is_self else { return nil }
  
  if let is_gallery = data.is_gallery, is_gallery, let galleryData = data.gallery_data?.items, let metadata = data.media_metadata {
    let galleryArr = galleryData.compactMap { item in
      let id = item.media_id
      if let itemMeta = metadata[String(id)], let extArr = itemMeta?.m?.split(separator: "/"), let size = itemMeta?.s, let imgURL = URL(string: "https://i.redd.it/\(id).\(extArr[extArr.count - 1])") {
        return MediaExtracted(url: imgURL, size: CGSize(width: size.x, height: size.y))
      }
      return nil
    }
    return .gallery(galleryArr)
  }
  
  if let videoPreview = data.preview?.reddit_video_preview, let url = videoPreview.hls_url, let videoURL = URL(string: url), let width = videoPreview.width, let height = videoPreview.height  {
    return .video(MediaExtracted(url: videoURL, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
  }
  
  if let redditVideo = data.media?.reddit_video, let url = redditVideo.hls_url, let videoURL = URL(string: url), let width = redditVideo.width, let height = redditVideo.height {
    return .video(MediaExtracted(url: videoURL, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
  }
  
  if data.media?.type == "youtube.com", let oembed = data.media?.oembed, let html = oembed.html, let ytID = extractYoutubeIdFromOEmbed(html), let width = oembed.width, let height = oembed.height, let author_name = oembed.author_name, let author_url = oembed.author_url, let authorURL = URL(string: author_url), let thumb = oembed.thumbnail_url, let thumbURL = URL(string: thumb) {
    let thumbReq = ImageRequest(url: thumbURL, processors: [.resize(width: getPostContentWidth(contentWidth: contentWidth))], priority: .normal)
    Post.prefetcher.startPrefetching(with: [thumbReq])
    let size = CGSize(width: CGFloat(width), height: CGFloat(height))
    let newExtracted = YTMediaExtracted(videoID: ytID, size: size, thumbnailURL: thumbURL, thumbnailRequest: thumbReq, player: YouTubePlayer(source: .video(id: ytID)), author: author_name, authorURL: authorURL)
    Caches.ytPlayers.addKeyValue(key: ytID, data: { newExtracted } )
    return .youtube(ytID, size)
  }
  
  
  if let postEmbed = data.crosspost_parent_list?.first {
//    return .repost(Post(data: postEmbed, api: RedditAPI.shared, fetchSub: true, contentWidth: getPostContentWidth(contentWidth: contentWidth, secondary: true) ))
    return .repost(Post(data: postEmbed, api: RedditAPI.shared, fetchSub: true, contentWidth: contentWidth, secondary: true ))
  }
  
  if IMAGES_FORMATS.contains(where: { data.url.hasSuffix($0) }), let url = rootURL(data.url) {
    var actualWidth = 0
    var actualHeight = 0
    if let images = data.preview?.images, images.count > 0, let image = images[0].source, let width = image.width, let height = image.height {
      actualWidth = width
      actualHeight = height
    }
    return .image(MediaExtracted(url: url, size: CGSize(width: actualWidth, height: actualHeight)))
  }
  
  if let images = data.preview?.images, images.count > 0, let image = images[0].source, let src = image.url?.replacing("/preview.", with: "/i."), !src.contains("external-preview"), let imgURL = rootURL(src.escape), let width = image.width, let height = image.height {
    return .image(MediaExtracted(url: imgURL, size: CGSize(width: width, height: height)))
  }
  
  if VIDEOS_FORMATS.contains(where: { data.url.hasSuffix($0) }), let url = URL(string: data.url) {
    return .video(MediaExtracted(url: url, size: CGSize(width: 0, height: 0)))
  }
  
  let actualURL = data.url.hasPrefix("/r/") || data.url.hasPrefix("/u/") ? "https://reddit.com\(data.url)" : data.url
  guard let urlComponents = URLComponents(string: actualURL) else {
    return nil
  }
  
  let pathComponents = urlComponents.path.components(separatedBy: "/").filter({ !$0.isEmpty })
  
  if urlComponents.host?.hasSuffix("reddit.com") == true || urlComponents.host?.hasSuffix("app.winston.lo.cafe") == true, pathComponents.count > 1 {
    switch pathComponents[0] {
    case "r":
      let subredditName = pathComponents[1]
      if pathComponents.count > 2 && pathComponents[2] == "comments" {
        let postId = pathComponents[3]
        if pathComponents.count >= 6 {
          let commentId = pathComponents[5]
          return .comment(id: commentId, postID: postId, subreddit: subredditName)
        }
        return .post(id: postId, subreddit: subredditName)
      }
      return .subreddit(name: subredditName)
      
    case "user", "u":
      let username = pathComponents[1]
      return .user(username: username)
      
    default:
      if !data.is_self, let linkURL = URL(string: data.url) {
        return .link(linkURL)
      }
    }
  }
  
  if data.post_hint == "link", let linkURL = URL(string: data.url) {
    return .link(linkURL)
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
