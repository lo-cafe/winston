//
//  VotesCounter.swift
//  winston
//
//  Created by Igor Marcossi on 18/07/23.
//

import SwiftUI
import Popovers
import Defaults

struct ViewVotesModifier: ViewModifier {
  @Default(.enableVotesPopover) private var enableVotesPopover
  @State private var show = false
  var ups: Int
  var downs: Int
  func body(content: Content) -> some View {
    content
      .scaleEffect(show ? 1.175 : 1)
      .contentShape(Rectangle())
      .highPriorityGesture(
        !enableVotesPopover
        ? nil
        : TapGesture().onEnded {
          withAnimation(spring) {
            show.toggle()
          }
        }
      )
      .popover(
        present: $show,
        attributes: {
          $0.position = .absolute(
            originAnchor: .left,
            popoverAnchor: .right
          )
          $0.rubberBandingMode = [.xAxis, .yAxis]
          $0.dismissal.dragDismissalProximity = CGFloat(50)
          //              $0.dismissal.mode = .dragDown
          //          $0.dismissal.tapOutsideIncludesOtherPopovers = true
          $0.presentation.transition = .fadeBlur
          $0.dismissal.transition = .fadeBlur
          $0.blocksBackgroundTouches = true
          $0.onTapOutside = { withAnimation { show = false } }
          $0.sourceFrameInset = .init(top: -12, left: -12, bottom: -12, right: -12)
        }
      ) {
        VStack {
          HStack {
            Image(systemName: "arrow.up.circle.fill")
            Text(String(ups))
          }
          .foregroundColor(.orange)
          HStack {
            Image(systemName: "arrow.down.circle.fill")
            Text(String(downs))
          }
          .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .fontSize(20, .semibold)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial).shadow(radius: 8))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.05), lineWidth: 0.5).padding(.all, 0.5))
      }
  }
}


extension View {
  func viewVotes(_ ups: Int, _ downs: Int) -> some View {
    self
      .modifier(ViewVotesModifier(ups: ups, downs: downs))
  }
}
