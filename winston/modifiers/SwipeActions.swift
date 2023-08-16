////
////  SwipeActions.swift
////  winston
////
////  Created by Igor Marcossi on 29/06/23.
////
//
import Foundation
import SwiftUI

struct SwipeUI<T: GenericRedditEntityDataType>: ViewModifier {
  private enum TriggeredAction: Int {
    case leftFirst = 1
    case leftSecond = 2
    case rightFirst = 3
    case rightSecond = 4
    case none = 0
  }
  
  @State private var pressing: Bool = false
  @State private var dragAmount: CGFloat = 0
  @State private var offset: CGFloat?
  @State private var firstLeftAction = false
  @State private var firstRightAction = false
  @State private var secondAction = false
  @State private var triggeredAction: TriggeredAction = .none
  
  var offsetYAction: CGFloat = 0
  var controlledDragAmount: Binding<CGFloat>?
  var controlledIsSource = true
  var onTapAction: (() -> Void)?
  var actionsSet: SwipeActionsSet
  @ObservedObject var entity: GenericRedditEntity<T>
  //  var leftActionIcon: String
  //  var rightActionIcon: String
  //  var secondActionIcon: String
  //  var leftActionHandler: (()->())?
  //  var rightActionHandler: (()->())?
  //  var secondActionHandler: (()->())?
  var disabled: Bool = false
  
  private let firstActionThreshold: CGFloat = 75
  private let secondActionThreshold: CGFloat = 175
  private let minimumDragDistance: CGFloat = 30
  
  func infoRight() -> (SwipeActionItem, SwipeActionItem, SwipeActionItem, Bool)? {
    let rightFirstNil = actionsSet.rightFirst.id == "none"
    let rightSecondNil = actionsSet.rightSecond.id == "none"
    var isSecond = false
    if !rightFirstNil || !rightSecondNil {
      var icon = !rightFirstNil ? actionsSet.rightFirst.icon : actionsSet.rightSecond.icon
      var textColor = !rightFirstNil ? actionsSet.rightFirst.color : actionsSet.rightSecond.color
      var bgColor = !rightFirstNil ? actionsSet.rightFirst.bgColor : actionsSet.rightSecond.bgColor
      if actionsSet.rightSecond.id != "none" && triggeredAction == .rightSecond {
        icon = actionsSet.rightSecond.icon
        textColor = actionsSet.rightSecond.color
        bgColor = actionsSet.rightSecond.bgColor
        isSecond = true
      }
      return (icon, textColor, bgColor, isSecond)
    }
    return nil
  }
  
  func infoLeft() -> (SwipeActionItem, SwipeActionItem, SwipeActionItem, Bool)? {
    let leftFirstNil = actionsSet.leftFirst.id == "none"
    let leftSecondNil = actionsSet.leftSecond.id == "none"
    var isSecond = false
    if !leftFirstNil || !leftSecondNil {
      var icon = !leftFirstNil ? actionsSet.leftFirst.icon : actionsSet.leftSecond.icon
      var textColor = !leftFirstNil ? actionsSet.leftFirst.color : actionsSet.leftSecond.color
      var bgColor = !leftFirstNil ? actionsSet.leftFirst.bgColor : actionsSet.leftSecond.bgColor
      if actionsSet.leftSecond.id != "none" && triggeredAction == .leftSecond {
        icon = actionsSet.leftSecond.icon
        textColor = actionsSet.leftSecond.color
        bgColor = actionsSet.leftSecond.bgColor
        isSecond = true
      }
      return (icon, textColor, bgColor, isSecond)
    }
    return nil
  }
  
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
          
          if let infoLeft = infoLeft() {
            let active = infoLeft.3 ? actionsSet.leftSecond.active(entity) : actionsSet.leftFirst.active(entity)
            MasterButton(icon: active ? infoLeft.0.active : infoLeft.0.normal, color: Color.hex(active ? infoLeft.2.active : infoLeft.2.normal), textColor: Color.hex(active ? infoLeft.1.active : infoLeft.1.normal), proportional: .circle) {}
              .scaleEffect(triggeredAction == .leftSecond ? 1.1 : triggeredAction == .leftFirst ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
              .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
              .frame(width: actualOffsetX < 0 ? 10 : abs(actualOffsetX))
              .offset(x: -8)
          }
          
          Spacer()
          
          if let infoRight = infoRight() {
            let active = infoRight.3 ? actionsSet.rightSecond.active(entity) : actionsSet.rightFirst.active(entity)
            MasterButton(icon: active ? infoRight.0.active : infoRight.0.normal, color: Color.hex(active ? infoRight.2.active : infoRight.2.normal), textColor: Color.hex(active ? infoRight.1.active : infoRight.1.normal), proportional: .circle) {}
              .scaleEffect(triggeredAction == .rightSecond ? 1.1 : triggeredAction == .rightFirst ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
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
          Task(priority: .background) { [triggeredAction] in
            
            switch triggeredAction {
            case .leftFirst:
              await actionsSet.leftFirst.action(entity)
            case .leftSecond:
              await actionsSet.leftSecond.action(entity)
            case .rightFirst:
              await actionsSet.rightFirst.action(entity)
            case .rightSecond:
              await actionsSet.rightSecond.action(entity)
            default:
              break
            }
          }
          withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) { triggeredAction = .none }
          return
        }
        
        var triggering: TriggeredAction = .none
        
        if (actionsSet.rightFirst.id != "none" && actionsSet.rightFirst.enabled(entity) && newValue >= firstActionThreshold) {
          triggering = .rightFirst
        }
        if actionsSet.rightSecond.id != "none" && actionsSet.rightSecond.enabled(entity) && (newValue) >= secondActionThreshold {
          triggering = .rightSecond
        }
        if (actionsSet.leftFirst.id != "none" && actionsSet.leftFirst.enabled(entity) && newValue <= -firstActionThreshold) {
          triggering = .leftFirst
        }
        if actionsSet.leftSecond.id != "none" && actionsSet.leftSecond.enabled(entity) && (newValue) <= -secondActionThreshold {
          triggering = .leftSecond
        }
        
        if triggering != triggeredAction {
          let increasing = triggering.rawValue > triggeredAction.rawValue
          let isSecond = triggering == .leftSecond || triggering == .rightSecond
          
          let impact = UIImpactFeedbackGenerator(style: increasing ? .rigid : .soft)
          impact.prepare()
          impact.impactOccurred()
//          try? haptics.fire(intensity: increasing ? 0.5 : 0.35, sharpness: increasing ? 0.25 : 0.5)
          withAnimation(isSecond ? .default.speed(2) : .interpolatingSpring(stiffness: 200, damping: 15, initialVelocity: increasing ? 35 : 0)) {
            triggeredAction = triggering
          }
        }
      }
    //      .simultaneousGesture(DragGesture())
  }
}

extension View {
  func swipyUI<T: GenericRedditEntityDataType>(
    offsetYAction: CGFloat = 0,
    controlledDragAmount: Binding<CGFloat>? = nil,
    controlledIsSource: Bool = true,
    onTap: (() -> Void)? = nil,
    actionsSet: SwipeActionsSet,
    entity: GenericRedditEntity<T>,
    disabled: Bool = false
  ) -> some View {
    self.modifier(SwipeUI(
      offsetYAction: offsetYAction,
      controlledDragAmount: controlledDragAmount,
      controlledIsSource: controlledIsSource,
      onTapAction: onTap,
      actionsSet: actionsSet,
      entity: entity,
      disabled: disabled))
  }
}
