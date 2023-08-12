//
//  VoteButton.swift
//  winston
//
//  Created by Daniel Inama on 12/08/23.
//

import SwiftUI
import SimpleHaptics
struct VoteButton: View {
  var color: Color
  var voteAction: RedditAPI.VoteAction
  var image: String
  var post: Post
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  @State private var animate = true

  var body: some View {
    Button {
      try? haptics.fire(intensity:  0.35, sharpness: 0.5)
      animate = false
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
        animate = true
      }
      Task {
        await post.vote(action: voteAction)
      }
    } label: {
      Image(systemName: image)
    }
    .buttonStyle(ScaleButtonStyle(scaleDepressed: 1, scalePressed: 1.2)) //Deperecated, but when I delete it the buttons in the feed stop working -_-
    .foregroundColor(color)
    .scaleEffect(animate ? 1 : 1.3)
    }
  }
