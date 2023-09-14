//
//  SwipeAnywhere.swift
//  winston
//
//  Created by Igor Marcossi on 16/08/23.
//

import SwiftUI
import Defaults

struct SwipeAywhereState {
  var activated = false
  var offset: CGSize = .zero
  var draggingRight: Bool? = nil
  var draggingLeft: Bool? = nil
}

struct SwipeAnywhere: ViewModifier {
  @StateObject var routerProxy: RouterProxy
  var forceEnable: Bool = false
  
  @Default(.enableSwipeAnywhere) private var enableSwipeAnywhere
  @GestureState private var dragState = SwipeAywhereState()
  @State private var staticOffset: CGSize = .zero
  let activatedAmount: CGFloat = 75
  @State private var rigid = UIImpactFeedbackGenerator(style: .rigid)
  @State private var soft = UIImpactFeedbackGenerator(style: .soft)
  
  func body(content: Content) -> some View {
    let enabled = routerProxy.router.path.count > 0 && (enableSwipeAnywhere || forceEnable)
    let finalOffset = dragState.offset + staticOffset
    let interpolate = interpolatorBuilder([0, activatedAmount], value: (abs(finalOffset.width) + abs(finalOffset.height)) / 2)
    content
    //left to right gesture
      .gesture(
        !enabled
        ? nil
        : DragGesture()
          .updating($dragState) { val, state, trans in
            if state.draggingRight.isNil { state.draggingRight = abs(val.translation.width) > abs(val.translation.height) }
            guard let dragging = state.draggingRight, dragging else { return }
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
            if routerProxy.router.path.count > 0 && val.translation.width > 0 && ((abs(val.translation.width) + abs(val.translation.height)) / 2) >= activatedAmount {
              routerProxy.router.path.removeLast(1)
            }
          }
      )
      .onChange(of: dragState.activated) { val in
        Task(priority: .background) {
          if !(dragState.draggingRight ?? false) { return }
          let impact = val ? rigid : soft
          impact.prepare()
          impact.impactOccurred()
        }
      }
    // right to left gesture
      .gesture(
        DragGesture()
          .updating($dragState){ value, state, trans in
            let direction = detectDirection(value: value)
            if direction == .right && value.startLocation.x > CGFloat(UIScreen.screenWidth - (100 - activatedAmount)) {
              let translation = value.translation
              state.draggingLeft = true
              state.offset = translation
            }
          }
          .onEnded{ value in
            let direction = detectDirection(value: value)
            if direction == .right && value.startLocation.x > CGFloat(UIScreen.screenWidth - (100 - activatedAmount)) {
              // your code here
              print("swiping right")
              routerProxy.tryToNavBack()
            }
          }
      )
    
    
      .overlay(
        Image(systemName: "arrowshape.right.fill")
          .fontSize(24, .semibold)
          .foregroundColor(.blue)
          .animation(.easeOut(duration: 0.2), value: (dragState.draggingLeft ?? false))
          .frame(width: 56, height: 56)
          .background(
            Circle().fill(.bar).shadow(radius: 8)
              .overlay(Circle().stroke(Color.primary.opacity(0.05), lineWidth: 0.5).padding(.all, 0.5))
          )
          .scaleEffect(interpolate([0.5, (dragState.draggingLeft ?? false) ? 1 : 0.9], true))
          .offset(x: routerProxy.router.lastPoppedView == nil ? UIScreen.screenWidth + 100 : 76 + finalOffset.width, y: finalOffset.height)
          .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .trailing)
          .ignoresSafeArea()
          .allowsHitTesting(false)
        //          .drawingGroup()
        , alignment: .bottomLeading
      )
      
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
          .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .leading)
          .ignoresSafeArea()
          .allowsHitTesting(false)
        //          .drawingGroup()
        , alignment: .bottomLeading
      )
  }
}

extension View {
  func swipeAnywhere(routerProxy: RouterProxy, forceEnable: Bool = false) -> some View {
    self.modifier(SwipeAnywhere(routerProxy: routerProxy, forceEnable: forceEnable))
  }
}

enum SwipeHVDirection: String {
  case left, right, up, down, none
}

func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
  if value.startLocation.x < value.location.x - 24 {
    return .left
  }
  if value.startLocation.x > value.location.x + 24 {
    return .right
  }
  if value.startLocation.y < value.location.y - 24 {
    return .down
  }
  if value.startLocation.y > value.location.y + 24 {
    return .up
  }
  return .none
}
