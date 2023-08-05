////
////  SwipeActions.swift
////  winston
////
////  Created by Igor Marcossi on 29/06/23.
////
//
import Foundation
import SwiftUI
import SimpleHaptics

struct SwipeUI: ViewModifier {
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  @State private var pressing: Bool = false
  @State private var dragAmount: CGFloat = 0
  @State private var offset: CGFloat?
  @State private var firstLeftAction = false
  @State private var firstRightAction = false
  @State private var secondAction = false
  
  var offsetYAction: CGFloat = 0
  var controlledDragAmount: Binding<CGFloat>?
  var controlledIsSource = true
  var onTapAction: (() -> Void)?
  var leftActionIcon: String
  var rightActionIcon: String
  var secondActionIcon: String
  var leftActionHandler: (()->())?
  var rightActionHandler: (()->())?
  var secondActionHandler: (()->())?
  var disabled: Bool = false
  
  private let firstActionThreshold: CGFloat = 75
  private let secondActionThreshold: CGFloat = 200
  private let minimumDragDistance: CGFloat = 30
  
  func body(content: Content) -> some View {
    let actualOffsetX = controlledDragAmount?.wrappedValue ?? dragAmount
    let offsetXInterpolate = interpolatorBuilder([0, firstActionThreshold], value: actualOffsetX)
    let offsetXNegativeInterpolate = interpolatorBuilder([0, -firstActionThreshold], value: actualOffsetX)
    
    content
      .offset(x: controlledDragAmount != nil ? 0 : dragAmount)
      .background(
        !controlledIsSource
        ? nil
        : HStack {
          
          if leftActionHandler != nil {
            MasterButton(icon: leftActionIcon, color: firstLeftAction ? .blue : .gray, textColor: .white, proportional: .circle) {
              
            }
            .scaleEffect(firstLeftAction ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX < 0 ? 10 : abs(actualOffsetX))
            .offset(x: -8)
          }
          
          Spacer()
          
          if rightActionHandler != nil {
            MasterButton(icon: secondAction ? secondActionIcon : rightActionIcon, color: secondAction ? .secondary.opacity(0.2) : firstRightAction ? .orange : .gray, textColor: secondAction ? .blue : .white, proportional: .circle) {
              
            }
            .scaleEffect(secondAction ? 1.1 : firstRightAction ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXNegativeInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX > 0 ? 10 : abs(actualOffsetX))
            .offset(x: 8)
          }
        }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .offset(y: offsetYAction)
          .allowsHitTesting(false)
      )
      .onTapGesture {
        onTapAction?()
      }
      .gesture(
        DragGesture(minimumDistance: minimumDragDistance, coordinateSpace: .local)
          .onChanged { val in
            let x = val.translation.width
            if offset == nil && x != 0 {
              offset = x < 0 ? -minimumDragDistance : minimumDragDistance
            }
            if let offset = offset {
              var transaction = Transaction()
              transaction.isContinuous = true
              transaction.animation = controlledDragAmount != nil ? nil : draggingAnimation
              
              withTransaction(transaction) {
                if controlledDragAmount != nil {
                  controlledDragAmount?.wrappedValue =  x - offset
                } else {
                  dragAmount = x - offset
                }
              }
            }
          }
          .onEnded { val in
            let x = val.translation.width
            let predictedEnd = val.predictedEndTranslation.width
            offset = nil
            let distance = abs(0 - x)
            var initialVel = abs(predictedEnd / distance)
            initialVel = initialVel < 3.75 ? 0 : initialVel * 2
            
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 17, initialVelocity: initialVel)) {
              if controlledDragAmount != nil {
                controlledDragAmount?.wrappedValue =  0
              } else {
                dragAmount = 0
              }
            }
          }
        , including: disabled ? .none : .all
      )
      .onChange(of: (controlledDragAmount?.wrappedValue ?? dragAmount)) { newValue in
        if !controlledIsSource { return }
        if newValue == 0 {
          if firstLeftAction {
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) {
              firstLeftAction = false
            }
            leftActionHandler?()
          } else if firstRightAction {
            if secondAction {
              withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) {
                secondAction = false
              }
              secondActionHandler?()
            } else {
              rightActionHandler?()
            }
          }
          return
        }
        let firstLeftActioning = (leftActionHandler != nil && newValue > firstActionThreshold - 1)
        let firstRightActioning = (rightActionHandler != nil && newValue < -firstActionThreshold + 1)
        let firstActioning = firstLeftActioning || firstRightActioning
        let secondActioning = (newValue) < -secondActionThreshold + 1
        if firstLeftAction != firstLeftActioning || firstRightAction != firstRightActioning {
          withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: firstActioning ? 35 : 0)) {
            firstLeftAction = firstLeftActioning
            firstRightAction = firstRightActioning
          }
          if abs(newValue) > 20 {
            try? haptics.fire(intensity: firstActioning ? 0.5 : 0.35, sharpness: firstActioning ? 0.25 : 0.5)
          }
        }
        if secondActionHandler != nil {
          if secondAction != secondActioning {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: secondActioning ? 35 : 0)) {
              secondAction = secondActioning
            }
            try? haptics.fire(intensity: secondActioning ? 0.5 : 0.35, sharpness: secondActioning ? 0.25 : 0.5)
          }
        }
      }
    //      .simultaneousGesture(DragGesture())
  }
}

extension View {
  func swipyUI(
    offsetYAction: CGFloat = 0,
    controlledDragAmount: Binding<CGFloat>? = nil,
    controlledIsSource: Bool = true,
    onTap: (() -> Void)? = nil,
    leftActionIcon: String = "arrow.down",
    rightActionIcon: String = "arrow.up",
    secondActionIcon: String = "arrowshape.turn.up.left.fill",
    leftActionHandler: (()->())? = nil,
    rightActionHandler: (()->())? = nil,
    secondActionHandler: (()->())? = nil,
    disabled: Bool = false
  ) -> some View {
    self.modifier(SwipeUI(
      offsetYAction: offsetYAction,
      controlledDragAmount: controlledDragAmount,
      controlledIsSource: controlledIsSource,
      onTapAction: onTap,
      leftActionIcon: leftActionIcon,
      rightActionIcon: rightActionIcon,
      secondActionIcon: secondActionIcon,
      leftActionHandler: leftActionHandler,
      rightActionHandler: rightActionHandler,
      secondActionHandler: secondActionHandler,
      disabled: disabled))
  }
}
