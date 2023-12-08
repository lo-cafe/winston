//
//  AccountSwitcherTarget.swift
//  winston
//
//  Created by Igor Marcossi on 26/11/23.
//

import SwiftUI
import Defaults
import Pow

func movePoint(point1: CGPoint, toward point2: CGPoint, when distanceLessThan: CGFloat) -> CGSize {
    let distance = hypot(point2.x - point1.x, point2.y - point1.y)
    
    guard distance < distanceLessThan else { return CGSize.zero }
    
    let t = 1 - (distance / distanceLessThan)
    let interpolationFactor = t * t
    let deltaX = interpolationFactor * (point2.x - point1.x)
    let deltaY = interpolationFactor * (point2.y - point1.y)
    return CGSize(width: deltaX, height: deltaY)
}

struct AccountSwitcherTarget: View, Equatable {
  static let size: Double = 56
  static let strokeWidth: Double = 3
  static let fontSize: Double = 12
  static let vStackSpacing: Double = 4
  static let hitboxTolerance: Double = 5
  
  static func == (lhs: AccountSwitcherTarget, rhs: AccountSwitcherTarget) -> Bool {
    lhs.cred == rhs.cred && lhs.index == rhs.index && lhs.hovered == rhs.hovered && lhs.willEnd == rhs.willEnd && lhs.distance == rhs.distance && lhs.fingerPos == rhs.fingerPos && lhs.attraction == rhs.attraction
  }
  
  @State private var appear = false
  @State private var jump = 0
  @State private var globalCirclePos: CGPoint = .zero
  @State private var impactRigid = UIImpactFeedbackGenerator(style: .rigid)
  
  var containerSize: CGSize
  var index: Int
  var targetsCount: Int
  var fingerPos: CGPoint
  var cred: RedditCredential? = nil
  var willEnd: Bool
  var selectCredential: (RedditCredential?) -> ()


  private let distanceMaxSelectedVibrating: Double = 100
  private let verticalOffset = -50.0
  private let textSpace = (AccountSwitcherTarget.fontSize * 1.2) + AccountSwitcherTarget.vStackSpacing
  private var isAddBtn: Bool { cred == nil }
  private var isSelected: Bool { !isAddBtn && Defaults[.redditCredentialSelectedID] == cred?.id }
  private var radiusX: Double { (containerSize.width / 2) }
  private var radiusY: Double { (containerSize.height / 2) }
  private var initialOffset: CGSize { getOffsetAroundCircleForIndex(count: targetsCount, index: index, circleSize: containerSize) }
  private var x: Double { initialOffset.width }
  private var y: Double { -initialOffset.height }
  private var xMin: Double { globalCirclePos.x - (AccountSwitcherTarget.size / 2) + x + radiusX }
  private var xMax: Double { xMin + AccountSwitcherTarget.size }
  private var yMin: Double { globalCirclePos.y - (AccountSwitcherTarget.size / 2) + verticalOffset + y }
  private var yMax: Double { yMin + AccountSwitcherTarget.size }
  private var attraction: CGSize {
    let targetPos = CGPoint(x: (xMin + xMax) / 2, y: (yMin + yMax) / 2)
    return movePoint(point1: targetPos, toward: fingerPos, when: 100)
  }
  private var distance: Double {
    return max( AccountSwitcherTarget.size / 2, min(distanceMaxSelectedVibrating, abs(CGPoint(x: (xMin + xMax) / 2, y: (yMin + yMax) / 2).distanceTo(point: fingerPos))))
  }
  private var hovered: Bool {
    let actualAttraction: CGSize = isSelected ? .zero : attraction
    let xRange = (xMin + actualAttraction.width - Self.hitboxTolerance)...(xMax + actualAttraction.width + Self.hitboxTolerance)
    let yRange = (yMin + actualAttraction.height - Self.hitboxTolerance)...(yMax + actualAttraction.height + Self.hitboxTolerance)
    return xRange.contains(fingerPos.x) && yRange.contains(fingerPos.y)
  }
  
  var body: some View {
    let interpolateVibration = interpolatorBuilder([0, distanceMaxSelectedVibrating], value: distance)
    let attractionOffset: CGSize = (isSelected ? .zero : attraction)
    let appearingOffset = CGSize(width: appear ? x + radiusX : 0, height: appear ? y + verticalOffset : 0)

    Group {
      if isAddBtn {
        Image(systemName: "plus")
          .fontSize(Self.size * 0.75, .semibold)
          .foregroundStyle(.primary)
      } else {
        Group {
          if let picture = cred?.profilePicture, let url = URL(string: picture) {
            URLImage(url: url).equatable()
          } else {
            Image(.emptyCredential).resizable()
          }
        }
        .scaledToFill()
        .background(.white)
      }
    }
    .frame(Self.size - (Self.strokeWidth * 2))
    .mask(Circle().fill(.black))
    .overlay(
      !isAddBtn
      ? nil
      : Image(systemName: "plus")
        .fontSize(Self.size * 0.75, .semibold)
        .foregroundStyle(Color.accentColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Circle().fill(.white))
        .mask(Circle().fill(.black).scaleEffect(hovered ? 1 : 0.001))
    )
    .overlay(isAddBtn ? nil : Circle().stroke(.white, lineWidth: Self.strokeWidth))
    .overlay(
      !isSelected
      ? nil
      : Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(Color.accentColor)
        .fontSize(16, .semibold)
        .frame(22)
        .background(Circle().fill(.white))
        .offset(x: 11 / 2, y: -11 / 2)
      , alignment: .topTrailing
    )
    .background(
      isSelected || (isAddBtn && !hovered)
      ? nil
      : Image(.spotlight)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(150)
    )
    .frame(Self.size)
    .changeEffect(.shake(rate: .fast), value: jump)
    .background(alignment: .top) {
      VStack(spacing: 2) {
        Text(isAddBtn ? "Add new" : cred?.userName ?? "Unknown")
          .fixedSize(horizontal: true, vertical: false)
          .foregroundStyle(.primary)
          .fontSize(Self.fontSize, .semibold)
//          .shadow(color: .black.opacity(0.35), radius: 13, x: 0, y: 8)
      }
      .frame(alignment: .top)
      .position(x: Self.size / 2, y: Self.size + Self.vStackSpacing + ((Self.fontSize * 1.2) / 2))
      .scaleEffect(1)
//      .offset(y: appear ? Self.size + Self.vStackSpacing : 0)
    }
    .compositingGroup()
    .shadow(color: .black.opacity(0.35), radius: 13, x: 0, y: 8)
    .floatingBounceEffect(disabled: isSelected || !appear || hovered)
    .scaleEffect(appear ? !isSelected && hovered ? 1.25 : 1 : 0.1)
    .blur(radius: appear ? 0 : 30)
    .brightness(!isSelected && hovered && !isAddBtn ? 0.5 : 0)
    .offset(attractionOffset + appearingOffset)
    .animation(hovered ? .spring(response: 0.4, dampingFraction: 0.5) : .spring, value: hovered)
    .animation(.bouncy, value: attraction)
    .opacity(appear ? 1 : 0)
    .background( GeometryReader { geo in Color.clear.onAppear {
      let frame = geo.frame(in: .global)
      impactRigid.prepare()
      withAnimation(.bouncy.delay(0.05 * Double((targetsCount - 1) - index))) {
        globalCirclePos = .init(x: frame.midX, y: frame.midY)
        self.appear = true
      }
    } } )
    .vibrate(.continuous(sharpness: hovered ? 0 : interpolateVibration([0.3, 0], false), intensity: hovered ? 0 : interpolateVibration([0.3, 0], false)), trigger: isSelected && !hovered ? distance : 0)
    .vibrate(.transient(sharpness: !isSelected && !hovered ? 1.0 : 0, intensity: isSelected && hovered ? 0 : 1.0), trigger: hovered)
    .onChange(of: willEnd) {
      guard $0 else { return }
      withAnimation(.snappy.delay(0.025 * Double(index))) { self.appear = false }
      if hovered { selectCredential(cred) }
    }
    .onChange(of: hovered) { if $0 && isSelected { jump += 1 } }
    .transition(.identity)
  }
}
