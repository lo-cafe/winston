//
//  SubredditIcon.swift
//  winston
//
//  Created by Igor Marcossi on 13/07/23.
//

import Foundation
import SwiftUI
import Nuke
import NukeUI

struct SubredditBaseIcon: View, Equatable {
  static func == (lhs: SubredditBaseIcon, rhs: SubredditBaseIcon) -> Bool {
    return lhs.iconURLStr == rhs.iconURLStr && lhs.id == rhs.id && lhs.name == rhs.name
  }
  
  let name: String
  let iconURLStr: String?
  let id: String
  var size: CGFloat = 30
  let color: String?
  
//  private static let pipeline = ImagePipeline {
//    $0.dataLoader = DataLoader(configuration: {
//      DataLoader.defaultConfiguration
//    }())
//    
//    $0.imageCache = ImageCache()
//    $0.dataCache = try? DataCache(name: "lo.cafe.winston-cache")
//  }
  
  var body: some View {
    if let icon = iconURLStr, !icon.isEmpty, let iconURL = URL(string: icon) {
//      LazyImage(url: iconURL, transaction: Transaction(animation: .default)) { state in
      LazyImage(url: iconURL) { state in
        if let image = state.image {
          image.resizable()
        } else if state.error != nil {
          Color.red.opacity(0.1)
            .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
        } else {
          Image(.loader)
            .resizable()
            .scaledToFill()
            .mask(Circle())
            .frame(maxWidth: 50, maxHeight: 50)
        }
      }
      .processors([.resize(width: size)])
//      .pipeline(SubredditBaseIcon.pipeline)
      .scaledToFill()
      .frame(width: size, height: size)
      .mask(Circle())
    } else {
      Text(String((name).prefix(1)).uppercased())
        .frame(width: size, height: size)
        .background(Color.hex(String((firstNonEmptyString(color, "#828282") ?? "").dropFirst(1))), in: Circle())
        .mask(Circle())
        .fontSize(CGFloat(Int(size * 0.535)), .semibold)
        .foregroundColor(.primary)
    }
  }
}

struct SubredditIcon: View, Equatable {
  static func == (lhs: SubredditIcon, rhs: SubredditIcon) -> Bool {
    lhs.data.community_icon == rhs.data.community_icon && lhs.data.icon_img == rhs.data.icon_img && lhs.data.display_name == rhs.data.display_name && lhs.data.id == rhs.data.id && lhs.data.primary_color == rhs.data.primary_color && lhs.data.key_color == rhs.data.key_color
  }
  var data: SubredditData
  var size: CGFloat = 30
  var body: some View {
    let communityIcon = data.community_icon?.split(separator: "?") ?? []
    let icon = data.icon_img == "" || data.icon_img == nil ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : data.icon_img
    SubredditBaseIcon(name: data.display_name ?? data.id, iconURLStr: icon == "" ? nil : icon, id: data.id, size: size, color: firstNonEmptyString(data.key_color, data.primary_color, "#828282") ?? "")
//      .equatable()
  }
}

func firstNonEmptyString(_ strings: String?...) -> String? {
    for string in strings {
        if let string = string, !string.isEmpty {
            return string
        }
    }
    return nil
}
