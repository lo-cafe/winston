//
//  getTagsFromTitle.swift
//  winston
//
//  Created by Igor Marcossi on 23/10/23.
//

import Foundation
import UIKit
import SwiftUI

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
  if data.over_18 ?? false { tags.append(.init(label: "NSFW", bgColor: UIColor(.red.opacity(0.9)), textColor: .white)) }
  if let flair = data.link_flair_text, let cleansed = flairWithoutEmojis(str: flair), !cleansed.joined().isEmpty {
    let hasBackground = data.link_flair_background_color != nil && !data.link_flair_background_color!.isEmpty
    let textColor: UIColor = hasBackground && data.link_flair_text_color != nil ? (data.link_flair_text_color! == "light" ? .white : .black) : .black
    let bgColor = hasBackground ? UIColor(hex: data.link_flair_background_color!) : UIColor(hex: "D5D7D9")
    tags.append(.init(label: cleansed.joined(separator: " "), bgColor: bgColor, textColor: textColor))
  }
  return tags
}
