//
//  previewSheet.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import SwiftUI

private let handlerWidth: CGFloat = 108
private let handlerDashWidth: CGFloat = 56
private let handlerHeight: CGFloat = 36
private let handlerRadius: CGFloat = 18
private let bodyRadius: CGFloat = 32

struct PreviewSheetModifier<T: View>: ViewModifier {
  var handlerBGOnly = false
  var scrollContentHeight: CGFloat
  @Binding var sheetContentSize: CGSize
  var forcedOffset: CGFloat = 0
  var sheetContent: (CGFloat) -> T
  var bg: any ShapeStyle
  var border = false
  @State private var disappear = true
  @State private var dragOffsetPersist: CGFloat = 0
  @GestureState private var dragOffsetRaw: CGFloat?
  @State private var initialDragOffset: CGFloat?
  @State private var currentStepIndex: Int = 0
  
  var pointZero: CGFloat { UIScreen.screenHeight - handlerHeight }
  var stepPoints: [CGFloat] { [pointZero - forcedOffset, pointZero - (sheetContentSize.height / 2) - max(0, forcedOffset - (sheetContentSize.height / 2)), pointZero - sheetContentSize.height] }
  
  func body(content: Content) -> some View {
    let dragOffset = dragOffsetRaw ?? 0
    let isDragging = initialDragOffset != nil
    let disabled = abs(sheetContentSize.height - forcedOffset) < 2
    let interpolate = interpolatorBuilder([handlerDashWidth, 0], value: abs(sheetContentSize.height - forcedOffset))
    let dragGesture = DragGesture(minimumDistance: 0)
      .updating($dragOffsetRaw) { val, state, trans in
        let y = val.translation.height
        if initialDragOffset == nil && y != 0 {
          Task {
            initialDragOffset = y
          }
        }
        if let initialDragOffset = initialDragOffset {
          trans.isContinuous = true
          //          trans.animation = .interpolatingSpring(stiffness: 1000, damping: 100)
          trans.animation = .interactiveSpring()
          withTransaction(trans) {
            state = y - initialDragOffset
          }
        }
      }
      .onEnded({ val in
        dragOffsetPersist = val.translation.height - (initialDragOffset ?? 0)
        guard let nextI = stepPoints.closest(to: stepPoints[currentStepIndex] + val.predictedEndTranslation.height) else { return }
        let newI = nextI
        let newY = stepPoints[newI]
        withAnimation(.spring()) {
          currentStepIndex = newI
          dragOffsetPersist = 0
        }
        
      })
    
    
    content
      .overlay(
        VStack {
          sheetContent(handlerHeight)
            .background(GeometryReader { g in Color.clear.onAppear { sheetContentSize = CGSize(width: g.size.width, height: g.size.height - handlerHeight) }.onChange(of: g.size) { sheetContentSize = CGSize(width: $0.width, height: $0.height - handlerHeight) } })
          //            .measure($sheetContentSize)
        }
        //          .onChange(of: sheetContentSize, perform: { newValue in
        //            print(newValue)
        //          })
        //          .padding(.top, handlerHeight)
          .frame(.screenSize,  .top)
          .mask(SheetShape(width: UIScreen.screenWidth, height: UIScreen.screenHeight).fill(.black))
          .overlay(
            Capsule(style: .continuous).fill(.ultraThinMaterial)
              .overlay(Capsule(style: .continuous).fill(.primary.opacity(!isDragging ? 0.15 : 0.3)))
              .frame(width: interpolate([handlerDashWidth - (isDragging ? 8 : 0), 8], false), height: isDragging ? 10 : 8)
              .padding(.top, 12)
              .animation(.spring(), value: isDragging)
              .allowsHitTesting(false)
            , alignment: .top
          )
          .background(
            SheetShape(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
              .fill(AnyShapeStyle(bg))
              .shadow(radius: 16)
              .allowsHitTesting(!disabled)
          )
//          .contentShape(.contextMenuPreview, SheetShape(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
//          .contentShape()
          .scaleEffect(1)
          .compositingGroup()
          .offset(y: max(stepPoints[stepPoints.count - 1], stepPoints[currentStepIndex] + dragOffset + dragOffsetPersist))
          .animation(.default, value: scrollContentHeight)
          .gesture(handlerBGOnly || disabled ? nil : dragGesture)
          .opacity(disappear ? 0 : 1)
          .offset(y: disappear ? handlerHeight : 0)
          .onAppear { doThisAfter(0.3) { withAnimation(spring) { disappear = false } } }
          .onChange(of: dragOffsetRaw == nil) { newValue in if newValue { initialDragOffset = nil } }
        , alignment: .bottom
      )
  }
}

extension View {
  func previewSheet(handlerBGOnly: Bool = false, scrollContentHeight: CGFloat, sheetContentSize: Binding<CGSize>, forcedOffset: CGFloat = 0, bg: any ShapeStyle, border: Bool = false, @ViewBuilder _ content: @escaping (CGFloat) -> (some View)) -> some View {
    self.modifier(PreviewSheetModifier(handlerBGOnly: handlerBGOnly, scrollContentHeight: scrollContentHeight, sheetContentSize: sheetContentSize, forcedOffset: forcedOffset, sheetContent: content, bg: bg, border: border))
  }
}


struct SheetShape: InsettableShape {
  var width: CGFloat
  var height: CGFloat
  var insetAmount = 0.0
  
  func inset(by amount: CGFloat) -> some InsettableShape {
    var arc = self
    arc.insetAmount += amount
    return arc
  }
  
  func path(in rect: CGRect) -> Path {
    //    let bodyHeight = height - handlerHeight
    
    var path = Path()
    
    // start from the top left corner of the handler
    path.move(to: CGPoint(x: ((width - handlerWidth) / 2 + handlerRadius) + insetAmount, y: 0 + insetAmount))
    
    // top edge of the handler
    path.addLine(to: CGPoint(x: ((width + handlerWidth) / 2 - handlerRadius) - insetAmount, y: 0 + insetAmount))
    
    // top right corner of the handler
    path.addArc(center: CGPoint(x: ((width + handlerWidth) / 2 - handlerRadius) - insetAmount, y: handlerRadius + insetAmount), radius: handlerRadius - insetAmount, startAngle: .radians(-1.5 * CGFloat.pi), endAngle: .radians(0), clockwise: false)
    
    // right edge of the handler
    path.addLine(to: CGPoint(x: ((width + handlerWidth) / 2) - insetAmount, y: (handlerHeight - handlerRadius) + insetAmount))
    
    // bottom right corner of the handler
    path.addArc(center: CGPoint(x: ((width + handlerWidth) / 2 + handlerRadius) + insetAmount, y: handlerHeight - handlerRadius + insetAmount), radius: handlerRadius + insetAmount, startAngle: .radians(CGFloat.pi), endAngle: .radians(0.5 * CGFloat.pi), clockwise: true)
    
    // connection between the handler and the body on the right side
    path.addLine(to: CGPoint(x: width - bodyRadius - insetAmount, y: handlerHeight + insetAmount))
    
    // top right corner of the body
    path.addArc(center: CGPoint(x: width - bodyRadius - insetAmount, y: handlerHeight + bodyRadius + insetAmount), radius: bodyRadius - insetAmount, startAngle: .radians(-0.5 * CGFloat.pi), endAngle: .radians(0), clockwise: false)
    
    // right edge of the body
    path.addLine(to: CGPoint(x: width - insetAmount, y: height - insetAmount))
    
    // bottom edge of the body
    path.addLine(to: CGPoint(x: 0, y: height - insetAmount))
    
    // left edge of the body
    path.addLine(to: CGPoint(x: 0, y: handlerHeight + bodyRadius + insetAmount))
    
    // top left corner of the body
    path.addArc(center: CGPoint(x: bodyRadius + insetAmount, y: handlerHeight + bodyRadius + insetAmount), radius: bodyRadius - insetAmount, startAngle: .radians(CGFloat.pi), endAngle: .radians(1.5 * CGFloat.pi), clockwise: false)
    
    // connection between the handler and the body on the left side
    path.addLine(to: CGPoint(x: ((width - handlerWidth) / 2) + insetAmount, y: handlerHeight + insetAmount))
    
    // bottom left corner of the handler
    path.addArc(center: CGPoint(x: ((width - handlerWidth) / 2 - handlerRadius) + insetAmount, y: (handlerHeight - handlerRadius) + insetAmount), radius: handlerRadius + insetAmount, startAngle: .radians(0.5 * CGFloat.pi), endAngle: .radians(0), clockwise: true)
    
    // left edge of the handler
    path.addLine(to: CGPoint(x: ((width - handlerWidth) / 2) + insetAmount, y: handlerRadius + insetAmount))
    
    // top left corner of the handler
    path.addArc(center: CGPoint(x: ((width - handlerWidth) / 2 + handlerRadius) + insetAmount, y: handlerRadius + insetAmount), radius:  handlerRadius - insetAmount, startAngle: .radians(CGFloat.pi), endAngle: .radians(-0.5 * CGFloat.pi), clockwise: false)
    
    return path
  }
}
