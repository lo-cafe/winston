//
//  SwipeActions.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import Foundation
import SwiftUI
import SimpleHaptics

struct SwipeActionsModifier: ViewModifier {
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  @GestureState var offsetX: CGFloat?
  @State private var offsetXTemp: CGFloat = .zero
  @State private var offsetOffset: CGFloat?
  @State private var firstAction = false
  @State private var secondAction = false
  
  var leftActionHandler: ()->()
  var rightActionHandler: ()->()
  var secondActionHandler: (()->())?
  
  let firstActionThreshold: CGFloat = 75
  let secondActionThreshold: CGFloat = 150
  let minimumDragDistance: CGFloat = 16
  
  init(leftActionHandler: @escaping ()->(), rightActionHandler: @escaping ()->(), secondActionHandler: (()->())? = nil) {
    self.leftActionHandler = leftActionHandler
    self.rightActionHandler = rightActionHandler
    self.secondActionHandler = secondActionHandler
  }
  
  func body(content: Content) -> some View {
    let actualOffsetX = (offsetX ?? 0) + offsetXTemp
    let pressing = actualOffsetX != 0
    let offsetXInterpolate = interpolatorBuilder([0, firstActionThreshold], value: actualOffsetX)
    let offsetXNegativeInterpolate = interpolatorBuilder([0, -firstActionThreshold], value: actualOffsetX)
    
    content
      .background(
        RR(20, .secondary.opacity(pressing ? 0.1 : 0))
          .padding(.vertical, -14)
          .padding(.horizontal, -16)
      )
      .offset(x: actualOffsetX)
      .background(
        HStack {
          
          MasterButton(icon: "arrow.down", color: firstAction ? .blue : .gray, textColor: .white, proportional: .circle) {
            
          }
          .scaleEffect(firstAction ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
          .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
          .frame(width: abs(actualOffsetX))
          .offset(x: -16)
          
          Spacer()
          
//          Group {
//            if secondActionHandler != nil && secondAction {
//              MasterButton(icon: "arrowshape.turn.up.left.fill", color: .secondary.opacity(0.2), textColor: .blue, proportional: .circle) {
//
//              }
//              .frame(width: abs(actualOffsetX))
//              .transition(.offset(x: 60).combined(with: .opacity))
//
//            } else {
              MasterButton(icon: secondAction ? "arrowshape.turn.up.left.fill" : "arrow.up", color: secondAction ? .secondary.opacity(0.2) : firstAction ? .orange : .gray, textColor: secondAction ? .blue : .white, proportional: .circle) {
                
              }
              .scaleEffect(secondAction ? 1.1 : firstAction ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
              .opacity(max(0, offsetXNegativeInterpolate([-0.9, 1], false)))
              .frame(width: abs(actualOffsetX))
//              .transition(.offset(x: -60).combined(with: .opacity))
              .offset(x: 16)
//            }
//          }
        }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      )
      .simultaneousGesture(
        DragGesture(minimumDistance: minimumDragDistance, coordinateSpace: .global)
          .updating($offsetX, body: { val, state, transaction in
            let x = val.translation.width
            Task {
              if offsetOffset == nil && x != 0 {
                offsetOffset = x < 0 ? -minimumDragDistance : minimumDragDistance
              }
            }
            if let offsetOffset = offsetOffset {
              transaction.isContinuous = true
              transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
              state = x - offsetOffset
            }
          })
          .onEnded { val in
            let predictedEnd = val.predictedEndTranslation.width
            let xPos = val.translation.width
            offsetXTemp = xPos - (offsetOffset ?? 0)
            let finalXPos: CGFloat = 0
            let distance = abs(finalXPos - xPos)
            var initialVel = abs(predictedEnd / distance)
            initialVel = initialVel < 3.75 ? 0 : initialVel * 2
            if firstAction {
              if secondAction {
                secondActionHandler?()
              } else {
                if xPos > 0 {
                  rightActionHandler()
                } else {
                  leftActionHandler()
                }
              }
            }
            
            doThisAfter(0) {
              withAnimation(.interpolatingSpring(stiffness: 150, damping: 17, initialVelocity: initialVel)) {
                offsetXTemp = finalXPos
              }
            }
            
          }
      )
      .onChange(of: offsetX) { _val in
        let val = _val ?? 0
        if _val != nil {
          let firstActioning = abs(val) > firstActionThreshold - 1
          let secondActioning = val < -secondActionThreshold + 1
          
          if (!firstAction && firstActioning) || (firstAction && !firstActioning) {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: firstActioning ? 35 : 0)) {
              firstAction = firstActioning
            }
            try? haptics.fire(intensity: firstActioning ? 0.5 : 0.35, sharpness: firstActioning ? 0.25 : 0.5)
          }
          if secondActionHandler != nil {
            if (!secondAction && secondActioning) || (secondAction && !secondActioning) {
              withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: secondActioning ? 35 : 0)) {
                secondAction = secondActioning
              }
              try? haptics.fire(intensity: secondActioning ? 0.5 : 0.35, sharpness: secondActioning ? 0.25 : 0.5)
            }
          }
        } else {
          offsetOffset = nil
          firstAction = false
          secondAction = false
        }
      }
  }
}

extension View {
  func swipyActions(leftActionHandler: @escaping ()->(), rightActionHandler: @escaping ()->(), secondActionHandler: (()->())? = nil) -> some View {
    self.modifier(SwipeActionsModifier(leftActionHandler: leftActionHandler, rightActionHandler: rightActionHandler, secondActionHandler: secondActionHandler))
  }
}
