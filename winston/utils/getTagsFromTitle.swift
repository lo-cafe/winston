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
  if let flair = Post.extractFlairData(data: data, checkDefaultsForColor: true) {
    tags.append(.init(label: flair.getFormattedText(), bgColor: UIColor(hex: flair.background_color), textColor: UIColor(hex: flair.text_color)))
  }
  return tags
}
