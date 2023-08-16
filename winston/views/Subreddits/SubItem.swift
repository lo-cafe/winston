//
//  SubItem.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import SwiftUI
import Defaults
struct SubItem: View {
  @ObservedObject var sub: Subreddit
  @Default(.likedButNotSubbed) var likedButNotSubbed
  var body: some View {
    if let data = sub.data {
      let favorite = data.user_has_favorited ?? false
      let localFav = likedButNotSubbed.contains(sub)
      NavigationLink(value: SubViewType.posts(sub)) {
        HStack {
          SubredditIcon(data: data)
          Text(data.display_name ?? "")
          
          Spacer()
          
          Image(systemName: "star.fill")
            .foregroundColor((favorite || localFav) ? .blue : .gray.opacity(0.3))
            .highPriorityGesture( TapGesture().onEnded { Task(priority: .background){ localFav ? _ = sub.localFavoriteToggle() : await sub.favoriteToggle() } } )
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.automatic)
      
    } else {
      Text("Error")
    }
  }
}
