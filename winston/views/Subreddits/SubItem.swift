//
//  SubItem.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import SwiftUI
import Defaults

struct SubItemButton: View {
  @Binding var selectedSub: FirstSelectable?
  @StateObject var sub: Subreddit
  var body: some View {
    if let data = sub.data {
      Button {
        selectedSub = .sub(sub)
      } label: {
        HStack {
          Text(data.display_name ?? "")
          SubredditIcon(data: data)
        }
      }
    }
  }
}

struct SubItem: View, Equatable {
  static func == (lhs: SubItem, rhs: SubItem) -> Bool {
    lhs.sub.id == rhs.sub.id && lhs.sub.data == rhs.sub.data && lhs.forcedMaskType == rhs.forcedMaskType
  }
  
  var forcedMaskType: CommentBGSide = .middle
  @Binding var selectedSub: FirstSelectable?
  @ObservedObject var sub: Subreddit
  var cachedSub: CachedSub? = nil
  @Default(.likedButNotSubbed) private var likedButNotSubbed
  
  func favoriteToggle() {
      if likedButNotSubbed.contains(sub) {
        _ = sub.localFavoriteToggle()
      } else {
        sub.favoriteToggle(entity: cachedSub)
      }
  }
  
  var body: some View {
    if let data = sub.data {
      let favorite = data.user_has_favorited ?? false
      let localFav = likedButNotSubbed.contains(sub)
      let isActive = selectedSub == .sub(sub) 
      WListButton(showArrow: !IPAD, active: isActive) {
        selectedSub = .sub(sub)
      } label: {
        HStack {
          SubredditIcon(data: data)
          Text(data.display_name ?? "")
            .foregroundStyle(isActive ? .white : .primary)
          
          Spacer()
          
          Image(systemName: "star.fill")
            .foregroundColor((favorite || localFav) ? Color.accentColor : .gray.opacity(0.3))
            .highPriorityGesture( TapGesture().onEnded(favoriteToggle) )
        }
      }
      .mask(CommentBG(cornerRadius: 10, pos: forcedMaskType).fill(.black))
      
    } else {
      Text("Error")
    }
  }
}
