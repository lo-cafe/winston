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
  var sub: Subreddit
  var body: some View {
    if let data = sub.data {
      Button {
        selectedSub = .sub(sub)
      } label: {
        HStack {
          Text(data.display_name ?? "")
          SubredditIcon(subredditIconKit: data.subredditIconKit)
        }
      }
    }
  }
}

struct SubItem: View {
  var forcedMaskType: CommentBGSide = .middle
  @Binding var selectedSub: FirstSelectable?
  @StateObject var sub: Subreddit
  var cachedSub: CachedSub
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
      let favorite = cachedSub.user_has_favorited
      let localFav = likedButNotSubbed.contains(sub)
      let isActive = selectedSub == .sub(sub) 
      WListButton(showArrow: !IPAD, active: isActive) {
        selectedSub = .sub(sub)
      } label: {
        HStack {
          SubredditIcon(subredditIconKit: data.subredditIconKit)
          Text(data.display_name ?? "")
            .foregroundStyle(isActive ? .white : .primary)
          
          Spacer()
          
          Image(systemName: "star.fill")
            .foregroundColor((favorite || localFav) ? Color.accentColor : .gray.opacity(0.3))
            .highPriorityGesture( TapGesture().onEnded(favoriteToggle) )
        }
      }
      
    } else {
      Text("Error")
    }
  }
}
