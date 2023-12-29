//
//  SubsNStuffLine.swift
//  winston
//
//  Created by Igor Marcossi on 24/09/23.
//

import SwiftUI

struct SubsNStuffLine: View, Equatable {
  static func == (lhs: SubsNStuffLine, rhs: SubsNStuffLine) -> Bool {
    true
  }
  
//  static let height = Tag.height + 4
  static let height: CGFloat = 1
  
  var showSub: Bool?
  var feedsAndSuch: [String]?
  var subredditIconKit: SubredditIconKit?
  var sub: Subreddit?
  var flair: String?
  var over18: Bool?
  
  var body: some View {
    HStack(spacing: 0) {
      WDivider()
    }
    .padding(.horizontal, 2)
    .frame(height: SubsNStuffLine.height)
    //    }
  }
}
