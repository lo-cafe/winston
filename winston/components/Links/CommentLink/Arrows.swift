//
//  Arrows.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI

enum ArrowKind {
  case straight
  case straightCurve
  case curve
  case empty
  
  var child: ArrowKind {
    switch self {
    case .straightCurve:
      return .straight
    case .curve:
      return .empty
    case .straight, .empty:
      return self
    }
  }
  
  var isStraight: Bool { self == .straight }
  var isStraightCurve: Bool { self == .straightCurve }
  var isCurve: Bool { self == .curve }
  var isEmpty: Bool { self == .empty }
}

struct Arrows: View {
  var kind: ArrowKind
  var body: some View {
      Group {
        switch kind {
        case .curve:
          CurveShape()
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
//            .padding(.top, -8)
        case .straight:
          StraightShape()
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -8)
        case .straightCurve:
          StraightCurveShape()
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -8)
        case .empty:
          Color.clear
        }
      }
      .padding(.all, 1)
      .frame(maxWidth: 12, maxHeight: .infinity, alignment: .topLeading)
  }
}

struct StraightShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    return path
  }
}

struct StraightCurveShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addArc(center: CGPoint(x: rect.minX + NEST_LINES_WIDTH, y: (rect.maxY / 2) - NEST_LINES_WIDTH), radius: NEST_LINES_WIDTH, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}

struct CurveShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addArc(center: CGPoint(x: rect.minX + NEST_LINES_WIDTH, y: (rect.maxY / 2) - NEST_LINES_WIDTH), radius: NEST_LINES_WIDTH, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}
