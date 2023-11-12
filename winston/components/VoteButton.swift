//
//  VoteButton.swift
//  winston
//
//  Created by Daniel Inama on 12/08/23.
//

import SwiftUI

@available(iOS 17.0, *)
struct VoteButton: View, Equatable {
  static func == (lhs: VoteButton, rhs: VoteButton) -> Bool {
    return lhs.active == rhs.active
  }
  
  var active: Bool
  var color: Color
//  var voteAction: () -> ()
  var image: String
  
  var body: some View {
    Image(systemName: image)
      .symbolEffect(active ? .bounce.up : .bounce.down, options: .speed(2.75), value: active)
      .frame(37)
      .background(Color.clear)
      .contentShape(Rectangle())
      .frame(21)
      .foregroundColor(active ? color : .gray)
  }
}

@available(iOS, deprecated: 17.0)
struct VoteButtonFallback: View, Equatable {
  static func == (lhs: VoteButtonFallback, rhs: VoteButtonFallback) -> Bool {
    return lhs.color == rhs.color && lhs.image == rhs.image
  }
  
  var color: Color
  var voteAction: () -> ()
  var image: String
  @State private var animate = true
  
  func action() {
    animate = false
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)){
      animate = true
    }
    voteAction()
  }
  
  var body: some View {
    Image(systemName: image)
      .frame(21)
      .background(Color.clear)
      .contentShape(Circle())
      .highPriorityGesture(TapGesture().onEnded(action))
      .foregroundColor(color)
      .scaleEffect(animate ? 1 : 1.3)
  }
}
