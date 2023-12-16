//
//  SwipeAnywhere.swift
//  winston
//
//  Created by Igor Marcossi on 16/08/23.
//

import SwiftUI
import Defaults
import Combine

struct SwipeAywhereState {
  var activated = false
  var offset: CGSize = .zero
  var dragging: Bool? = nil
}

struct SwipeAnywhere: ViewModifier {
  @ObservedObject private var tabsManager = Nav.shared
  var forceEnable: Bool = false
  
  @Default(.BehaviorDefSettings) private var behaviorDefSettings
  @GestureState private var dragState = SwipeAywhereState()
  @State private var staticOffset: CGSize = .zero
  let activatedAmount: CGFloat = 75
  @State private var rigid = UIImpactFeedbackGenerator(style: .rigid)
  @State private var soft = UIImpactFeedbackGenerator(style: .soft)
  
  func body(content: Content) -> some View {
    let enableSwipeAnywhere = behaviorDefSettings.enableSwipeAnywhere
    let isAtRoot = tabsManager.activeRouter.isAtRoot
    let enabled = !isAtRoot && (enableSwipeAnywhere || forceEnable)
    let finalOffset = dragState.offset + staticOffset
    let interpolate = interpolatorBuilder([0, activatedAmount], value: (abs(finalOffset.width) + abs(finalOffset.height)) / 2)
    content
      .gesture(
        !enabled
        ? nil
        : DragGesture()
          .updating($dragState) { val, state, trans in
            if state.dragging == nil { state.dragging = abs(val.translation.width) > abs(val.translation.height) }
            guard let dragging = state.dragging, dragging else { return }
            let translation = val.translation
            trans.isContinuous = true
            var newDragState = state
            let newActivated = translation.width > 0 && ((abs(translation.width) + abs(translation.height)) / 2) >= activatedAmount
            trans.animation = newActivated != newDragState.activated ? .interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: newActivated ? 35 : 0) : .interpolatingSpring(stiffness: 1000, damping: 100)
            
            
            newDragState.activated = newActivated
            newDragState.offset = translation
            state = newDragState
          }
          .onEnded { val in
            let predictedEnd = val.predictedEndTranslation
            staticOffset = val.translation
            let distance = (abs(staticOffset.width) + abs(staticOffset.height)) / 2
            var initialVel = abs(((abs(predictedEnd.width) + abs(predictedEnd.height)) / 2) / distance)
            initialVel = initialVel < 3.75 ? 0 : initialVel * 3
            withAnimation(.interpolatingSpring(stiffness: 125, damping: 15, initialVelocity: -initialVel)) {
              staticOffset = .zero
            }
            if !isAtRoot && val.translation.width > 0 && ((abs(val.translation.width) + abs(val.translation.height)) / 2) >= activatedAmount {
              Nav.back()
            }
          }
      )
      .onChange(of: dragState.activated) { val in
        Task(priority: .background) {
          if !(dragState.dragging ?? false) { return }
          let impact = val ? rigid : soft
          impact.prepare()
          impact.impactOccurred()
        }
      }
      .overlay(
        !enableSwipeAnywhere && !forceEnable
        ? nil
        : Image(systemName: "arrowshape.left\(dragState.activated ? ".fill" : "")")
          .fontSize(24, .semibold)
          .foregroundColor(dragState.activated ? .blue : .primary)
          .animation(.easeOut(duration: 0.2), value: dragState.activated)
          .frame(width: 56, height: 56)
          .background(
            Circle().fill(.bar).shadow(radius: 8)
              .overlay(Circle().stroke(Color.primary.opacity(0.05), lineWidth: 0.5).padding(.all, 0.5))
          )
          .scaleEffect(interpolate([0.5, dragState.activated ? 1 : 0.9], true))
          .offset(x: -76 + finalOffset.width, y: finalOffset.height)
          .frame(.screenSize,  .leading)
          .ignoresSafeArea()
          .allowsHitTesting(false)
        //          .drawingGroup()
        , alignment: .bottomLeading
      )
  }
}

extension View {
  func swipeAnywhere(forceEnable: Bool = false) -> some View {
    self.modifier(SwipeAnywhere(forceEnable: forceEnable))
  }
}
