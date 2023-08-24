//
//  Arrows.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI
import Defaults

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
  var color: Color = ArrowColorPalette.monochrome.rawVal.first!
  var body: some View {
      Group {
        switch kind {
        case .curve:
          CurveShape()
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
//            .padding(.top, -8)
        case .straight:
          StraightShape()
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -8)
        case .straightCurve:
          StraightCurveShape()
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
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

enum ArrowColorPalette: Codable, CaseIterable, Identifiable, Defaults.Serializable{
  
  var id: [Color]{
    self.rawVal
  }
  
  case monochrome
  case rainbow
  case ibm
  case ocean
  case forest
  case fire
  
  var rawVal: [Color] {
    switch self{
    case .monochrome:
      [Color("divider")]
    case .ibm:
      [Color(hex: 0x648FFF), Color(hex: 0x785EF0), Color(hex: 0xDC267F), Color(hex: 0xFE6100), Color(hex: 0xFFB000)]
    case .ocean:
      [Color(hex: 0x00bf7d), Color(hex: 0x00b4c5), Color(hex: 0x0073e6), Color(hex: 0x2546f0), Color(hex: 0x5928ed)]
    case .forest:
      [Color(hex: 0xc0f9cc), Color(hex: 0xa4f5b5), Color(hex: 0x54ed7e), Color(hex: 0x44d669), Color(hex: 0x32c055)]
    case .fire:
      [Color(hex: 0xf6b4b6), Color(hex: 0xee8c8f), Color(hex: 0xe10623), Color(hex: 0xc7041b), Color(hex: 0xae0213)]
    case .rainbow:
      [Color(hex: 0xFF0000), Color(hex: 0xFF7F00), Color(hex: 0xFFFF00), Color(hex: 0x00FF00), Color(hex: 0x0000FF), Color(hex: 0x4B0082), Color(hex: 0x8F00FF)]
    }
  }
  
}


