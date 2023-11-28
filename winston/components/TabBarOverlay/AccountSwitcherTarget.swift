//
//  AccountSwitcherTarget.swift
//  winston
//
//  Created by Igor Marcossi on 26/11/23.
//

import SwiftUI
import Defaults

struct AccountSwitcherTarget: View, Equatable {
  static let size: Double = 48
  static let fontSize: Double = 12
  static let vStackSpacing: Double = 4
  static let floatOffsetVariationAmount: Double = 10
  
  static func == (lhs: AccountSwitcherTarget, rhs: AccountSwitcherTarget) -> Bool {
    lhs.account == rhs.account && lhs.index == rhs.index && lhs.hovered == rhs.hovered && lhs.willEnd == rhs.willEnd
  }
  
  @Default(.redditCredentialSelectedID) private var redditCredentialSelectedID
  @State private var floatOffset: CGSize = .zero
  @State private var timer = Timer.publish(every: 0.75, on: .main, in: .default).autoconnect()
  @State private var appear = false
  @State private var impactRigid = UIImpactFeedbackGenerator(style: .rigid)
  @State private var impactSoft = UIImpactFeedbackGenerator(style: .soft)
  
  
  var containerSize: CGSize
  var index: Int
  var targetsCount: Int
  var fingerPos: CGPoint
  var account: RedditCredential
  var willEnd: Bool
  
  private let verticalOffset = -50.0
  private var radiusX: Double { (containerSize.width / 2) }
  private var radiusY: Double { (containerSize.height / 2) }
  private var x: Double { self.calculateXOffset(count: targetsCount, index: index) }
  private var y: Double { -self.calculateYOffset(count: targetsCount, index: index) }
  private var hovered: Bool {
    let extra = (AccountSwitcherTarget.fontSize * 1.2) + AccountSwitcherTarget.vStackSpacing
    let targetSize = AccountSwitcherTarget.size + AccountSwitcherTarget.floatOffsetVariationAmount
    let xMin = ((UIScreen.screenWidth - targetSize) / 2) + x + radiusX
    let xMax = xMin + targetSize
    let yMin = UIScreen.screenHeight - getSafeArea().bottom + verticalOffset - extra - (targetSize / 2) + y
    let yMax = yMin + targetSize
    let xRange = xMin...xMax
    let yRange = yMin...yMax
    return xRange.contains(fingerPos.x) && yRange.contains(fingerPos.y)
  }
  
  var eccentricity: Double { sqrt(1 - pow(min(radiusX, radiusY) / max(radiusX, radiusY), 2)) }
  
  
  func calculateXOffset(count: Int, index: Int) -> Double {
//        let t = Double.pi * Double(index) / Double(max(1, count-1))
    let t = calculateT(count: count, index: index)
    let e = eccentricity
    let theta = t + (pow(e, 2)/8 + pow(e, 4)/16 + 71*pow(e, 6)/2048) * sin(2*t) +
    (5*pow(e, 4)/256 + 5*pow(e, 6)/256) * sin(4*t) +
    29*pow(e, 6)/6144 * sin(6*t)
    
    let xOffset = radiusX * cos(theta) - radiusX
    return xOffset
  }
  
  func calculateYOffset(count: Int, index: Int) -> Double {
//        let t = Double.pi * Double(index) / Double(max(1, count-1))
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
    let isSelected = redditCredentialSelectedID == account.id
    let hovered = hovered && account.isAuthorized && !isSelected
    //    let appear = !willEnd && appear
    VStack(spacing: Self.vStackSpacing) {
      Group {
        if let picture = account.profilePicture, let url = URL(string: picture) {
          URLImage(url: url)
        } else {
          Image(.emptyCredential).resizable()
        }
      }
      .scaledToFill()
      .frame(Self.size)
      .mask(Circle().fill(.black))
      .overlay(Circle().stroke(.white, lineWidth: 3))
      .background(
        ZStack {
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 30)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 20)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 10)
          Circle().fill(Color.hex("F2DDFF")).blur(radius: 5)
        }
      )
      .onReceive(timer) { _ in
        withAnimation(.smooth.speed(0.15)) {
          let range = (0-(Self.floatOffsetVariationAmount/2))...(0+(Self.floatOffsetVariationAmount/2))
          floatOffset = .init(width: .random(in: range), height: .random(in: range))
        }
      }
      
      VStack(spacing: 2) {
        Text(account.userName ?? "Unknown")
          .foregroundStyle(.white)
          .shadow(radius: 8, y: 4)
          .fontSize(Self.fontSize, .semibold)
        if isSelected {
          Text("ACTIVE")
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
            .font(Font(UIFont.systemFont(ofSize: 12, weight: .semibold, width: .condensed)))
            .padding(.vertical, 1)
            .padding(.horizontal, 4)
            .background(RR(4, Color.accentColor))
        }
      }
    }
    .blur(radius: appear ? 0 : 30)
    .compositingGroup()
    .offset(hovered ? .zero : floatOffset)
    .brightness(hovered ? 0.5 : 0)
    .scaleEffect(hovered ? 1.2 : 1)
    .animation(hovered ? .snappy.speed(2) : .smooth, value: hovered)
    .offset(x: appear ? x + radiusX : 0, y: appear ? y + verticalOffset : 0)
    .scaleEffect(appear ? 1 : 0.75)
    .opacity(appear ? 1 : 0)
    .onChange(of: willEnd) {
      if $0 {
        withAnimation(.snappy.delay(0.025 * Double(index))) { self.appear = false }
        var wasHovered = hovered
        doThisAfter(0.4) { if wasHovered {
          redditCredentialSelectedID = account.id
        } }
      }
    }
    .onAppear {
      impactRigid.prepare()
      withAnimation(.bouncy.delay(0.05 * Double((targetsCount - 1) - index))) { self.appear = true }
    }
    .onChange(of: hovered) { val in
      if val {
        impactRigid.prepare()
        impactRigid.impactOccurred()
        impactSoft.prepare()
      } else {
        impactSoft.prepare()
        impactSoft.impactOccurred()
        impactRigid.prepare()
      }
    }
    .transition(.identity)
  }
}
