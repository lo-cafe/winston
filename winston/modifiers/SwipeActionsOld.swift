//
//  SwipeActions.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import Foundation
import SwiftUI

struct SwipeActionsModifier: ViewModifier {
  var offsetY: CGFloat? = nil
  var disableAnimations = false
  var disableSwipe = false
  var disableFunctions = false
  @Binding var pressing: Bool
  @State private var offsetX: CGFloat = 0
  var parentOffsetX: Binding<CGFloat>?
  @State private var firstAction = false
  @State private var secondAction = false
  @State private var dragging = false
  var parentDragging: Binding<Bool>?
  
  var onTapAction: (() -> Void)?
  var leftActionIcon: String
  var rightActionIcon: String
  var secondActionIcon: String
  var leftActionHandler: (()->())?
  var rightActionHandler: (()->())?
  var secondActionHandler: (()->())?
  var disabled: Bool = false
  
  private let firstActionThreshold: CGFloat = 75
  private let secondActionThreshold: CGFloat = 150
  private let minimumDragDistance: CGFloat = 16
  
  init(offsetY: CGFloat? = nil, disableSwipe: Bool = false, disableFunctions: Bool = false, pressing: Binding<Bool>, parentDragging: Binding<Bool>? = nil, parentOffsetX: Binding<CGFloat>? = nil, leftActionIcon: String = "arrow.down", rightActionIcon: String = "arrow.up", secondActionIcon: String = "arrowshape.turn.up.left.fill", firstAction: Bool = false, secondAction: Bool = false, onTapAction: ( () -> Void)? = nil, leftActionHandler: (() -> Void)? = nil, rightActionHandler: (() -> Void)? = nil, secondActionHandler: (() -> Void)? = nil, disabled: Bool) {
    self.offsetY = offsetY
    self.disableSwipe = disableSwipe
    self.disableFunctions = disableFunctions
    self._pressing = pressing
    if let parentOffsetX = parentOffsetX {
      self.parentOffsetX = parentOffsetX
    }
    if let parentDragging = parentDragging {
      self.parentDragging = parentDragging
    }
    self.firstAction = firstAction
    self.secondAction = secondAction
    self.onTapAction = onTapAction
    self.leftActionIcon = leftActionIcon
    self.rightActionIcon = rightActionIcon
    self.secondActionIcon = secondActionIcon
    self.leftActionHandler = leftActionHandler
    self.rightActionHandler = rightActionHandler
    self.secondActionHandler = secondActionHandler
    self.disabled = disabled
  }
  
  func body(content: Content) -> some View {
    let actualOffsetX = parentOffsetX?.wrappedValue ?? offsetX
    let offsetXInterpolate = interpolatorBuilder([0, firstActionThreshold], value: actualOffsetX)
    let offsetXNegativeInterpolate = interpolatorBuilder([0, -firstActionThreshold], value: actualOffsetX)
    
    content
      .if(!disableFunctions) { view in
        view
          .offset(x: offsetX)
          .background(
            HStack {
              
              if leftActionHandler != nil {
                MasterButton(icon: leftActionIcon, color: firstAction ? .blue : .gray, textColor: .white, proportional: .circle) {
                  
                }
                .scaleEffect(firstAction ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
                .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
                .frame(width: abs(actualOffsetX))
                .offset(x: -16)
              }
              
              Spacer()
              
              if rightActionHandler != nil {
                MasterButton(icon: secondAction ? secondActionIcon : rightActionIcon, color: secondAction ? .secondary.opacity(0.2) : firstAction ? .orange : .gray, textColor: secondAction ? .blue : .white, proportional: .circle) {
                  
                }
                .scaleEffect(secondAction ? 1.1 : firstAction ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
                .opacity(max(0, offsetXNegativeInterpolate([-0.9, 1], false)))
                .frame(width: abs(actualOffsetX))
                .offset(x: 16)
              }
            }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .offset(y: offsetY ?? 0)
              .allowsHitTesting(false)
          )
      }
      .background(
        TappableView(
          minimumDragDistance: 8,
          onTap: {
            onTapAction?()
          },
//                    onPress: { val in
////                      print("smao")
//                      withAnimation(spring) {
//                        pressing = val
//                      }
//                    },
          onDragChanged: disableSwipe
          ? nil
          : { cancel, translation, startLocation, velocity in
            if parentDragging == nil {
              dragging = true
            } else {
              parentDragging?.wrappedValue = true
            }
            if disabled { return }
            var transaction = Transaction()
            transaction.isContinuous = true
            transaction.animation = disableAnimations ? nil : .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
            withTransaction(transaction) {
              if parentOffsetX != nil {
                parentOffsetX?.wrappedValue = translation.x
              } else {
                offsetX = translation.x
              }
            }
            

          },
          onDragEnded: disableSwipe
          ? nil
          : { translation, velocity in
            if disabled { return }
            if parentDragging == nil {
              dragging = false
            } else {
              parentDragging?.wrappedValue = false
            }
            if firstAction {
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) {
                  firstAction = false
                }
              if secondAction {
                  withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) {
                    secondAction = false
                  }
                secondActionHandler?()
              } else {
                if translation.x > 0 {
                  leftActionHandler?()
                } else {
                  rightActionHandler?()
                }
              }
            }
            let initialVel = -(abs(velocity.x) / 60)
            
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 17, initialVelocity: initialVel)) {
              if parentOffsetX != nil {
                parentOffsetX?.wrappedValue = 0
              } else {
                offsetX = 0
              }
            }
          }
        )
      )
      .onChange(of: (parentOffsetX?.wrappedValue ?? offsetX)) { newValue in
        if !disableFunctions && (parentDragging?.wrappedValue ?? dragging) {
          let firstActioning = (rightActionHandler != nil && newValue < -firstActionThreshold + 1) || (leftActionHandler != nil && newValue > firstActionThreshold - 1)
          let secondActioning = (newValue) < -secondActionThreshold + 1
          if firstAction != firstActioning {
              withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: firstActioning ? 35 : 0)) {
                firstAction = firstActioning
              }
            if abs(newValue) > 20 {
              let impact = UIImpactFeedbackGenerator(style: firstActioning ? .rigid : .soft)
              impact.prepare()
              impact.impactOccurred()
//              try? haptics.fire(intensity: firstActioning ? 0.5 : 0.35, sharpness: firstActioning ? 0.25 : 0.5)
            }
          }
          if secondActionHandler != nil {
            if secondAction != secondActioning {
              withAnimation(.interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: secondActioning ? 35 : 0)) {
                secondAction = secondActioning
              }
              let impact = UIImpactFeedbackGenerator(style: secondActioning ? .rigid : .soft)
              impact.prepare()
              impact.impactOccurred()
//                try? haptics.fire(intensity: secondActioning ? 0.5 : 0.35, sharpness: secondActioning ? 0.25 : 0.5)
            }
          }
        }
      }
    //      .simultaneousGesture(DragGesture())
  }
}

extension View {
  func swipyActions(offsetY: CGFloat? = nil, disableSwipe: Bool = false, disableFunctions: Bool = false, pressing: Binding<Bool>, parentDragging: Binding<Bool>? = nil, parentOffsetX: Binding<CGFloat>? = nil, onTap: (() -> Void)? = nil, leftActionIcon: String = "arrow.down", rightActionIcon: String = "arrow.up", secondActionIcon: String = "arrowshape.turn.up.left.fill", leftActionHandler: (()->())? = nil, rightActionHandler: (()->())? = nil, secondActionHandler: (()->())? = nil, disabled: Bool = false) -> some View {
    self.modifier(SwipeActionsModifier(
      offsetY: offsetY,
      disableSwipe: disableSwipe,
      disableFunctions: disableFunctions,
      pressing: pressing,
      parentDragging: parentDragging,
      parentOffsetX: parentOffsetX,
      leftActionIcon: leftActionIcon,
      rightActionIcon: rightActionIcon,
      secondActionIcon: secondActionIcon,
      onTapAction: onTap,
      leftActionHandler: leftActionHandler,
      rightActionHandler: rightActionHandler,
      secondActionHandler: secondActionHandler,
      disabled: disabled))
  }
}
