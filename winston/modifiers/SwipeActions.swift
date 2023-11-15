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

enum TriggeredAction: Int {
  case leftFirst = 1
  case leftSecond = 2
  case rightFirst = 3
  case rightSecond = 4
  case none = 0
}


struct SwipeUI<T: GenericRedditEntityDataType, B: Hashable>: ViewModifier {
  @Default(.enableSwipeAnywhere) private var enableSwipeAnywhere
  @State private var dragAmount: CGFloat = 0
  @State private var offset: CGFloat?
  @State private var triggeredAction: TriggeredAction = .none
  
  var secondary: Bool
  var offsetYAction: CGFloat = 0
  var controlledDragAmount: Binding<CGFloat>?
  var controlledIsSource = true
  var onTapAction: (() -> Void)?
  var actionsSet: SwipeActionsSet
  weak var entity: GenericRedditEntity<T, B>?
  var disabled: Bool = false
  
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
  
  func body(content: Content) -> some View {
    let actualOffsetX = controlledDragAmount?.wrappedValue ?? dragAmount
    let offsetXInterpolate = interpolatorBuilder([0, firstActionThreshold], value: actualOffsetX)
    let offsetXNegativeInterpolate = interpolatorBuilder([0, -firstActionThreshold], value: actualOffsetX)
    
    content
      .offset(x: controlledDragAmount != nil ? 0 : dragAmount)
      .background(
        !controlledIsSource || enableSwipeAnywhere
        ? nil
        : HStack {
          
          SwipeUIBtn(info: infoRight(), secondActiveFunc: actionsSet.rightSecond.active, firstActiveFunc: actionsSet.rightFirst.active, entity: entity!)
          //            .equatable()
            .scaleEffect(triggeredAction == .rightSecond ? 1.1 : triggeredAction == .rightFirst ? 1 : max(0.001, offsetXInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX < 0 ? 10 : abs(actualOffsetX))
            .offset(x: -8)
          
          Spacer()
          
          SwipeUIBtn(info: infoLeft(), secondActiveFunc: actionsSet.leftSecond.active, firstActiveFunc: actionsSet.leftFirst.active, entity: entity!)
          //            .equatable()
            .scaleEffect(triggeredAction == .leftSecond ? 1.1 : triggeredAction == .leftFirst ? 1 : max(0.001, offsetXNegativeInterpolate([-0.9, 0.85], false)))
            .opacity(max(0, offsetXNegativeInterpolate([-0.9, 1], false)))
            .frame(width: actualOffsetX > 0 ? 10 : abs(actualOffsetX))
            .offset(x: 8)
        }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .offset(y: offsetYAction)
          .allowsHitTesting(false)
      )
      .highPriorityGesture(secondary ? TapGesture().onEnded({ onTapAction?() }) : nil)
      .gesture(secondary ? nil : TapGesture().onEnded({ onTapAction?() }))
      .gesture(
        enableSwipeAnywhere
        ? nil
        : DragGesture(minimumDistance: 30, coordinateSpace: .local)
          .onChanged { val in
            let x = val.translation.width
            if offset == nil && x != 0 {
              offset = x
            }
            if let offset = offset {
              if controlledDragAmount != nil {
                controlledDragAmount?.wrappedValue =  x - offset
              } else {
                dragAmount = x - offset
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
            
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 16, initialVelocity: initialVel)) {
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
              await actionsSet.leftFirst.action(entity!)
            case .leftSecond:
              await actionsSet.leftSecond.action(entity!)
            case .rightFirst:
              await actionsSet.rightFirst.action(entity!)
            case .rightSecond:
              await actionsSet.rightSecond.action(entity!)
            default:
              break
            }
          }
          withAnimation(.interpolatingSpring(stiffness: 150, damping: 17)) { triggeredAction = .none }
          return
        }
        
        var triggering: TriggeredAction = .none
        
        if (actionsSet.rightFirst.id != "none" && actionsSet.rightFirst.enabled(entity!) && newValue >= firstActionThreshold) {
          triggering = .rightFirst
        }
        if actionsSet.rightSecond.id != "none" && actionsSet.rightSecond.enabled(entity!) && (newValue) >= secondActionThreshold {
          triggering = .rightSecond
        }
        if (actionsSet.leftFirst.id != "none" && actionsSet.leftFirst.enabled(entity!) && newValue <= -firstActionThreshold) {
          triggering = .leftFirst
        }
        if actionsSet.leftSecond.id != "none" && actionsSet.leftSecond.enabled(entity!) && (newValue) <= -secondActionThreshold {
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

struct SwipeUIBtn<T: GenericRedditEntityDataType, B: Hashable>: View, Equatable {
  //struct SwipeUIBtn: View {
  static func == (lhs: SwipeUIBtn<T, B>, rhs: SwipeUIBtn<T, B>) -> Bool {
    lhs.entity == rhs.entity && lhs.info?.0 == rhs.info?.0 && lhs.info?.1 == rhs.info?.1 && lhs.info?.2 == rhs.info?.2 && lhs.info?.3 == rhs.info?.3
  }
  
  var info: (SwipeActionItem, SwipeActionItem, SwipeActionItem, Bool)?
  var secondActiveFunc: (GenericRedditEntity<T, B>) -> Bool
  var firstActiveFunc: (GenericRedditEntity<T, B>) -> Bool
  weak var entity: GenericRedditEntity<T, B>?
  
  var body: some View {
    if let info = info {
      let active = info.3 ? secondActiveFunc(entity!) : firstActiveFunc(entity!)
      Image(systemName: active ? info.0.active : info.0.normal)
      //      Image(systemName: "square.and.arrow.up.circle.fill")
        .ifIOS17({ img in
          if #available(iOS 17, *) {
            img.contentTransition(.symbolEffect)
          } else {
            img
              .transition(.scaleAndBlur)
              .id(active ? info.0.active : info.0.normal)
          }
        })
        .frame(36)
        .background(Circle().fill(Color.hex(active ? info.2.active : info.2.normal)))
        .foregroundStyle(Color.hex(active ? info.1.active : info.1.normal))
        .allowsHitTesting(false)
        .compositingGroup()
        .fontSize(16, .semibold)
    }
  }
}

extension View {
  func swipyUI<T: GenericRedditEntityDataType, B: Hashable>(
    offsetYAction: CGFloat = 0,
    controlledDragAmount: Binding<CGFloat>? = nil,
    controlledIsSource: Bool = true,
    onTap: (() -> Void)? = nil,
    actionsSet: SwipeActionsSet,
    entity: GenericRedditEntity<T, B>,
    disabled: Bool = false,
    secondary: Bool = false
  ) -> some View {
    self.modifier(SwipeUI(
      secondary: secondary,
      offsetYAction: offsetYAction,
      controlledDragAmount: controlledDragAmount,
      controlledIsSource: controlledIsSource,
      onTapAction: onTap,
      actionsSet: actionsSet,
      entity: entity,
      disabled: disabled))
  }
}
