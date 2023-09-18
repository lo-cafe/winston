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
  var offset: CGFloat = 0
  @Environment(\.useTheme) private var selectedTheme
  var body: some View {
    let curve = selectedTheme.comments.theme.indentCurve
    let avatarSize = selectedTheme.comments.theme.badge.avatar.size
      Group {
        switch kind {
        case .curve:
          CurveShape(offset: offset, curve: curve, avatarSize: avatarSize)
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        case .straight:
          StraightShape()
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -1)
        case .straightCurve:
          StraightCurveShape(offset: offset, curve: curve, avatarSize: avatarSize)
            .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .padding(.vertical, -1)
        case .empty:
          Color.clear
        }
      }
      .padding(.all, 1)
      .frame(maxWidth: curve, maxHeight: .infinity, alignment: .topLeading)
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
  var offset: CGFloat = 0
  var curve: CGFloat
  var avatarSize: CGFloat
  func path(in rect: CGRect) -> Path {
    let threshold = (avatarSize - (curve * 2)) / 2
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addArc(center: CGPoint(x: rect.minX + curve, y: rect.minY + offset + threshold), radius: curve, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}

struct CurveShape: Shape {
  var offset: CGFloat = 0
  var curve: CGFloat
  var avatarSize: CGFloat
  func path(in rect: CGRect) -> Path {
    let threshold = (avatarSize - (curve * 2)) / 2
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    if offset != 0 {
      path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + offset + threshold))
    }
    if curve == 0 {
      path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + offset + threshold))
    }
    path.addArc(center: CGPoint(x: rect.minX + curve, y: rect.minY + offset + threshold), radius: curve, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}
