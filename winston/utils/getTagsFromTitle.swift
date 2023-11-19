//
//  getTagsFromTitle.swift
//  winston
//
//  Created by Igor Marcossi on 23/10/23.
//

import Foundation

func getTagsFromTitle(_ post: Post) -> [PrependTag] {
  var tags: [PrependTag] = []
  if let data = post.data { tags = getTagsFromTitleRaw(data) }
  return tags
}


func getTagsFromTitle(_ data: PostData) -> [PrependTag] {
  return getTagsFromTitleRaw(data)
}


func getTagsFromTitleRaw(_ data: PostData) -> [PrependTag] {
  var tags: [PrependTag] = []
  if data.over_18 ?? false { tags.append(.init(label: "NSFW", bgColor: .red.opacity(0.25))) }
  if let flair = data.link_flair_text { tags.append(.init(label: flair, bgColor: .primary.opacity(0.2))) }
  return tags
}
