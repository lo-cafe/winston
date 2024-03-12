//
//  FloatingMainTrigger.swift
//  winston
//
//  Created by Igor Marcossi on 28/12/23.
//

import SwiftUI
import Defaults

struct FloatingMainTrigger: View, Equatable {
  static func == (lhs: FloatingMainTrigger, rhs: FloatingMainTrigger) -> Bool {
    lhs.menuOpen == rhs.menuOpen && lhs.toggled == rhs.toggled && lhs.disable == rhs.disable
  }
  
  @Binding var menuOpen: Bool
  @Binding var showingFilters: Bool
  let dismiss: ()->()
  let size: Double
  let actionsSize: Double

  @State private var toggled = false
  @State private var disable = false
  @State private var vibrationTimer: Timer? = nil
  @State private var toggleTimer: Timer? = nil
  @GestureState private var pressingDown = false
  
  @Default(.SubredditFeedDefSettings) var subredditFeedDefSettings
  
  private let longPressDuration: Double = 0.275
  
  var body: some View {
    Image(systemName: toggled || menuOpen ? "xmark" : "slider.horizontal.3")
      .contentTransition(.symbolEffect)
      .transaction { trans in
        trans.animation = .easeInOut(duration: longPressDuration)
      }
      .fontSize(22, .bold)
      .frame(width: size, height: size)
      .foregroundColor(menuOpen || toggled ? .pink : Color.accentColor)
      .brightness((toggled || menuOpen ? 0.35 : 0) + (pressingDown ? 0.1 : 0))
      .background(Circle().fill(.white.opacity((toggled || menuOpen ? 0.5 : 0) + (pressingDown ? 0.225 : 0))).blendMode(.overlay))
      .floating()
      .scaleEffect((menuOpen || toggled ? actionsSize / size : 1) * (pressingDown ? 0.85 : 1))
      .increaseHitboxOf(size, by: 1.125, shape: Circle(), disable: menuOpen)
      .animation(.bouncy(duration: longPressDuration, extraBounce: 0.225), value: pressingDown)
      .highPriorityGesture(
        LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
          .updating($pressingDown) { isPressing, state, trans in
            trans.isContinuous = true
            state = isPressing
          }
        , including: disable ? .none : .all
      )
      .simultaneousGesture(
        DragGesture(minimumDistance: 0)
          .onChanged { val in
            let trans = val.translation
            if max(abs(trans.width), abs(trans.height)) > 24 {
              withAnimation(.snappy(duration: 0.2, extraBounce: 0.3)) { toggled = false }
              disable = true
              doThisAfter(0) { disable = false }
              toggleTimer?.invalidate()
            }
          }
      )
      .simultaneousGesture(TapGesture().onEnded({
        if menuOpen {
          dismiss()
        } else if subredditFeedDefSettings.openOptionsOnTap  {
          Hap.shared.play(intensity: 0.75, sharpness: 0.4)
          withAnimation(.snappy(extraBounce: 0.3)) {
            menuOpen = true
            toggled = false
          }
          doThisAfter(0) {
            withAnimation {
              showingFilters = true
            }
          }
        }
      }))
      .allowsHitTesting(!disable)
      .onChange(of: pressingDown) {
        if $0 {
          if menuOpen { return }
          Hap.shared.updateContinuous(intensity: 0, sharpness: 0)
          Hap.shared.startContinuous()
          vibrationTimer = createTimer(seconds: longPressDuration) { currLoop, totalLoops in
            let interpolate = interpolatorBuilder([0, CGFloat(totalLoops)], value: CGFloat(currLoop))
            Hap.shared.updateContinuous(intensity: Float(interpolate([0, 0.45], false)), sharpness: 0)
          }
          toggleTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
            vibrationTimer?.invalidate()
            Hap.shared.stopContinuous()
            Hap.shared.updateContinuous(intensity: 0, sharpness: 0)
            Hap.shared.play(intensity: 0.95, sharpness: 0.75)
            withAnimation(.snappy(duration: longPressDuration, extraBounce: 0.4)) {
              toggled = true
            }
          }
        } else {
          vibrationTimer?.invalidate()
          Hap.shared.stopContinuous()
          if toggled {
            Hap.shared.play(intensity: 1, sharpness: 0.95)
            withAnimation(.snappy(extraBounce: 0.3)) {
              menuOpen = true
              toggled = false
            }
            doThisAfter(0) {
              withAnimation {
                showingFilters = true
              }
            }
          } else {
            toggleTimer?.invalidate()
          }
        }
      }
  }
}
