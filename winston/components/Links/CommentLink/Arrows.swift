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
            .padding(.vertical, -1)
        case .straightCurve:
          StraightCurveShape()
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -1)
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
      [Color(hex: 0x0370C2), Color(hex: 0x0190FB), Color(hex: 0x00C3FA), Color(hex: 0x0090FC), Color(hex: 0x23A0FF)]
    case .forest:
      [Color(hex: 0x275036), Color(hex: 0x55713B), Color(hex: 0x318F28), Color(hex: 0x98CB6D), Color(hex: 0xA8BF65)]
    case .fire:
      [Color(hex: 0xFF0000), Color(hex: 0xD40000), Color(hex: 0xCF5B00), Color(hex: 0xcFF7C00), Color(hex: 0xF0A208)]
    case .rainbow:
      [Color(hex: 0xF44236), Color(hex: 0xFE922D), Color(hex: 0x2C704B), Color(hex: 0x0D73DC), Color(hex: 0x653996)]
    }
  }
  
}


