////
////  SwipeActions.swift
////  winston
////
////  Created by Igor Marcossi on 29/06/23.
////
//
import Foundation
import SwiftUI
import Defaults

struct SwipeRevolution<T: GenericRedditEntityDataType, B: Hashable>: ViewModifier, Equatable {
  static func == (lhs: SwipeRevolution<T, B>, rhs: SwipeRevolution<T, B>) -> Bool {
    //    lhs.entity == rhs.entity && lhs.size == rhs.size && lhs.actionsSet == rhs.actionsSet
    //    lhs.size == rhs.size && lhs.actionsSet == rhs.actionsSet
    lhs.entity?.id == rhs.entity?.id
  }
  
  //struct SwipeRevolution: ViewModifier {
  @Default(.enableSwipeAnywhere) private var enableSwipeAnywhere
  //  @State private var pressing: Bool = false
  @State private var dragAmount: CGFloat = 0
  @State private var triggeredAction: TriggeredAction = .none
  //
  var size: CGSize
  var offsetYAction: CGFloat = 0
  var controlledDragAmount: Binding<CGFloat>?
  var controlledIsSource = true
  var onTapAction: (() -> Void)?
  var actionsSet: SwipeActionsSet
  weak var entity: GenericRedditEntity<T, B>?
  var disabled: Bool = false
  //  @ViewBuilder var content: (UIViewController?) -> Content
  
  private let firstActionThreshold: CGFloat = 75
  private let secondActionThreshold: CGFloat = 150
  
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
  
  func dragChanged(_ cancel: @escaping () -> Void, _ translation: CGPoint, _ location: CGPoint, _ velocity: CGPoint) {
    if let entity = entity {
      let x = translation.x
      if controlledDragAmount != nil {
        controlledDragAmount?.wrappedValue =  x
      } else {
        dragAmount = x
      }
      
      let newValue = x
      
      //        if let entity = entity {
      if !controlledIsSource { return }
      
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
        Task {
          let impact = UIImpactFeedbackGenerator(style: increasing ? isSecond ? .heavy : .medium : .soft)
          impact.prepare()
          impact.impactOccurred()
        }
        //          try? haptics.fire(intensity: increasing ? 0.5 : 0.35, sharpness: increasing ? 0.25 : 0.5)
        //      withAnimation(.interpolatingSpring(stiffness: 175, damping: 12, initialVelocity: increasing ? 35 : 0)) {
        withAnimation(.interpolatingSpring(stiffness: 175, damping: 14, initialVelocity: increasing ? 35 : 0)) {
          triggeredAction = triggering
        }
      }
    }
  }
  
  func dragEnded(_ translation: CGPoint, _ velocity: CGPoint) {
    if let entity = entity {
      var initialVel = abs(velocity.x) / abs(translation.x)
      if (velocity.x > 0 && translation.x > 0) || (velocity.x < 0 && translation.x < 0) { initialVel = -initialVel }
      
      
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
      
      withAnimation(.interpolatingSpring(stiffness: 150, damping: 16, initialVelocity: initialVel)) {
        if controlledDragAmount != nil {
          controlledDragAmount?.wrappedValue =  0
        } else {
          dragAmount = 0
        }
        triggeredAction = .none
      }
    }
  }
  
  func body(content: Content) -> some View {
    if let entity = entity {
      let actualOffsetX = controlledDragAmount?.wrappedValue ?? dragAmount
      let offsetXInterpolate = interpolatorBuilder([0, firstActionThreshold], value: actualOffsetX)
      let offsetXNegativeInterpolate = interpolatorBuilder([0, -firstActionThreshold], value: actualOffsetX)
      
      GesturerHolder(id: entity.id, size: size, directions: .horizontal, onTap: nil, onDragChanged:dragChanged, onDragEnded: dragEnded, disabled: false, content: content)
      //      content(nil)
      .frame(width: size.width, height: size.height)
      .offset(x: dragAmount)
//      .transaction { if dragAmount != 0 { $0.animation = nil } }
      .background(
        !controlledIsSource || enableSwipeAnywhere || dragAmount == 0
        ? nil
        : HStack {
          
          SwipeUIBtn(info: infoRight(), secondActiveFunc: actionsSet.rightSecond.active, firstActiveFunc: actionsSet.rightFirst.active, entity: entity)
          //            .equatable()
            .scaleEffect(triggeredAction == .rightSecond ? 1.25 : triggeredAction == .rightFirst ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX < 0 ? 10 : abs(actualOffsetX))
            .offset(x: -8)
          
          Spacer()
          
          SwipeUIBtn(info: infoLeft(), secondActiveFunc: actionsSet.leftSecond.active, firstActiveFunc: actionsSet.leftFirst.active, entity: entity)
          //            .equatable()
            .scaleEffect(triggeredAction == .leftSecond ? 1.25 : triggeredAction == .leftFirst ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXNegativeInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX > 0 ? 10 : abs(actualOffsetX))
            .offset(x: 8)
        }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .offset(y: offsetYAction)
          .allowsHitTesting(false)
        //        .animation(nil, value: dragAmount)
        //        .animation(nil, value: dragAmount)
      )
      //      .onChange(of: (controlledDragAmount?.wrappedValue ?? dragAmount), perform: toggleActions)
    }
  }
}

extension View {
  func swipyRev<T: GenericRedditEntityDataType, B: Hashable>(
    size: CGSize,
    actionsSet: SwipeActionsSet,
    entity: GenericRedditEntity<T, B>?
  ) -> some View {
    self.modifier(SwipeRevolution(
      size: size,
      actionsSet: actionsSet,
      entity: entity
      //      id: entity?.id ?? ""
    ))
    //    self.modifier(SwipeRevolution(size: size))
  }
}
