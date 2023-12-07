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

    if distance < distanceLessThan {
        let t = 1 - (distance / distanceLessThan) // Normal interpolation
        let interpolationFactor = t * t // Ease in
        let deltaX = interpolationFactor * (point2.x - point1.x)
        let deltaY = interpolationFactor * (point2.y - point1.y)
        return CGSize(width: deltaX, height: deltaY)
    } else {
        return CGSize.zero
    }
}

struct AccountSwitcherTarget: View, Equatable {
  static let size: Double = 54
  static let strokeWidth: Double = 3
  static let fontSize: Double = 12
  static let vStackSpacing: Double = 4
  static let floatOffsetVariationAmount: Double = 10
  
  static func == (lhs: AccountSwitcherTarget, rhs: AccountSwitcherTarget) -> Bool {
    lhs.cred == rhs.cred && lhs.index == rhs.index && lhs.hovered == rhs.hovered && lhs.willEnd == rhs.willEnd && lhs.distance == rhs.distance && lhs.fingerPos == rhs.fingerPos
  }
  
  @Default(.redditCredentialSelectedID) private var redditCredentialSelectedID
  @State private var floatOffset: CGSize = .zero
  @State private var timer = Timer.publish(every: 0.75, on: .main, in: .default).autoconnect()
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

  private let distanceMaxSelectedVibrating: Double = 100
  private let verticalOffset = -50.0
  private let textSpace = (AccountSwitcherTarget.fontSize * 1.2) + AccountSwitcherTarget.vStackSpacing
  private let actualTargetSize = AccountSwitcherTarget.size
  private var isAddBtn: Bool { cred == nil }
  private var isSelected: Bool { !isAddBtn && redditCredentialSelectedID == cred?.id }
  private var radiusX: Double { (containerSize.width / 2) }
  private var radiusY: Double { (containerSize.height / 2) }
  private var x: Double { self.calculateXOffset(count: targetsCount, index: index) }
  private var y: Double { -self.calculateYOffset(count: targetsCount, index: index) }
  private var xMin: Double { globalCirclePos.x - (AccountSwitcherTarget.size / 2) + x + radiusX - Self.strokeWidth }
  private var xMax: Double { xMin + actualTargetSize + (Self.strokeWidth * 2) }
  private var yMin: Double { globalCirclePos.y - (AccountSwitcherTarget.size / 2) + verticalOffset + y - Self.strokeWidth }
  private var yMax: Double { yMin + actualTargetSize + (Self.strokeWidth * 2) }
  private var attraction: CGSize {
    let targetPos = CGPoint(x: (xMin + xMax) / 2, y: (yMin + yMax) / 2)
    return movePoint(point1: targetPos, toward: fingerPos, when: 70)
  }
  private var distance: Double {
    return max( AccountSwitcherTarget.size / 2, min(distanceMaxSelectedVibrating, abs(CGPoint(x: (xMin + xMax) / 2, y: (yMin + yMax) / 2).distanceTo(point: fingerPos))))
  }
  private var hovered: Bool {
    let actualAttraction: CGSize = isSelected ? .zero : attraction
    let xRange = (xMin + (actualAttraction.width * 2))...(xMax + (actualAttraction.width * 2))
    let yRange = (yMin + (actualAttraction.height * 2))...(yMax + (actualAttraction.height * 2))
    return xRange.contains(fingerPos.x) && yRange.contains(fingerPos.y)
  }
  
  private var eccentricity: Double { sqrt(1 - pow(min(radiusX, radiusY) / max(radiusX, radiusY), 2)) }

  func calculateXOffset(count: Int, index: Int) -> Double {
    if count == 1 { return -radiusX }
    let t = calculateT(count: count, index: index)
    let e = eccentricity
    let theta = t + (pow(e, 2)/8 + pow(e, 4)/16 + 71*pow(e, 6)/2048) * sin(2*t) +
    (5*pow(e, 4)/256 + 5*pow(e, 6)/256) * sin(4*t) +
    29*pow(e, 6)/6144 * sin(6*t)
    
    let xOffset = radiusX * cos(theta) - radiusX
    return xOffset
  }
  
  func calculateYOffset(count: Int, index: Int) -> Double {
    if count == 1 { return radiusY }
    let t = calculateT(count: count, index: index)
    let e = eccentricity
    let theta = t + (pow(e, 2)/8 + pow(e, 4)/16 + 71*pow(e, 6)/2048) * sin(2*t) +
    (5*pow(e, 4)/256 + 5*pow(e, 6)/256) * sin(4*t) +
    29*pow(e, 6)/6144 * sin(6*t)
    
    let yOffset = radiusY * sin(theta)
    return yOffset
  }
  
  private func calculateT(count: Int, index: Int) -> Double {
    let angleSpread: Double = .pi / 3
    let minItemCountForFullSpread: Int = 4
    let actualAngleSpread: Double
    if count >= minItemCountForFullSpread {
      actualAngleSpread = .pi
    } else {
      actualAngleSpread = angleSpread + Double(count - 1) * (.pi - angleSpread) / Double(minItemCountForFullSpread - 1)
    }
    let t = actualAngleSpread * Double(index) / Double(max(1, count-1)) + .pi / 2 - actualAngleSpread / 2
    return t
  }
  
  var body: some View {
    let interpolateVibration = interpolatorBuilder([0, distanceMaxSelectedVibrating], value: distance)
    //    let appear = !willEnd && appear
    VStack(spacing: Self.vStackSpacing) {
      Group {
        if isAddBtn {
          Image(systemName: "plus")
            .fontSize(Self.size * 0.75, .semibold)
            .foregroundStyle(hovered ? .white : .primary)
        } else {
          if let picture = cred?.profilePicture, let url = URL(string: picture) {
            URLImage(url: url).equatable()
          } else {
            Image(.emptyCredential).resizable()
          }
        }
      }
      .scaledToFill()
      .frame(Self.size - Self.strokeWidth)
      .background(Circle().fill(Color.accentColor).scaleEffect(hovered ? 1 : 0.1))
      .background(GeometryReader { geo in Color.clear.onAppear {
       let frame = geo.frame(in: .global)
        globalCirclePos = .init(x: frame.midX, y: frame.midY)
      } })
      .mask(Circle().fill(.black))
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
        isSelected || isAddBtn
        ? nil
        : ZStack {
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 30)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 20)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 10)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 5)
        }
      )
      .onReceive(timer) { _ in
        if isSelected { return }
        withAnimation(.smooth.speed(0.15)) {
          let range = (0-(Self.floatOffsetVariationAmount/2))...(0+(Self.floatOffsetVariationAmount/2))
          floatOffset = .init(width: .random(in: range), height: .random(in: range))
        }
      }
      
      VStack(spacing: 2) {
        Text(isAddBtn ? "Add new" : cred?.userName ?? "Unknown")
          .foregroundStyle(.primary)
          .shadow(radius: 8, y: 4)
          .fontSize(Self.fontSize, .semibold)
      }
      .vibrate(.continuous(sharpness: hovered ? 0 : interpolateVibration([0.3, 0], false), intensity: hovered ? 0 : interpolateVibration([0.3, 0], false)), trigger: isSelected && !hovered ? distance : 0)
      .vibrate(.transient(sharpness: !isSelected && !hovered ? 1.0 : 0, intensity: isSelected && hovered ? 0 : 1.0), trigger: hovered)
    }
    .changeEffect(.shake(rate: .fast), value: jump)
    .blur(radius: appear ? 0 : 30)
    .compositingGroup()
    .offset(hovered ? .zero : floatOffset)
    .brightness(!isSelected && hovered && !isAddBtn ? 0.5 : 0)
    .scaleEffect(!isSelected && hovered ? 1.2 : 1)
    .animation(hovered ? .spring(response: 0.5, dampingFraction: 0.525) : .smooth, value: hovered)
    .offset(x: appear ? x + radiusX : 0, y: appear ? y + verticalOffset : 0)
    .offset(isSelected ? .zero : attraction)
    .scaleEffect(appear ? 1 : 0.1)
    .opacity(appear ? 1 : 0)
    .onChange(of: willEnd) {
      if $0 {
        withAnimation(.snappy.delay(0.025 * Double(index))) { self.appear = false }
        let wasHovered = hovered
        if wasHovered {
          doThisAfter(0.4) {
            if let cred = cred {
              redditCredentialSelectedID = cred.id
            } else {
              TempGlobalState.shared.editingCredential = .init()
            }
          }
        }
      }
    }
    .onAppear {
      impactRigid.prepare()
      withAnimation(.bouncy.delay(0.05 * Double((targetsCount - 1) - index))) { self.appear = true }
    }
    .onChange(of: hovered) { val in
      if val && isSelected {
       jump += 1
      }
    }
    .transition(.identity)
  }
}
