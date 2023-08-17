//
//  VoteButton.swift
//  winston
//
//  Created by Daniel Inama on 12/08/23.
//

import SwiftUI

struct VoteButton: View {
  var color: Color
  var voteAction: RedditAPI.VoteAction
  var image: String
  var post: Post
  @State private var animate = true

  var body: some View {
    Button {
      let medium = UIImpactFeedbackGenerator(style: .medium)
      medium.prepare()
      medium.impactOccurred()
//      try? haptics.fire(intensity:  0.45, sharpness: 0.65)
      animate = false
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
        animate = true
      }
      Task(priority: .background) {
        await post.vote(action: voteAction)
      }
    } label: {
      Image(systemName: image)
    }
    .onTapGesture {}
    .buttonStyle(ScaleButtonStyle(scaleDepressed: 1, scalePressed: 1.2))
    .foregroundColor(color)
    .scaleEffect(animate ? 1 : 1.3)
    }
  }
