//
//  AccountSwitcherTarget.swift
//  winston
//
//  Created by Igor Marcossi on 26/11/23.
//

import SwiftUI

struct AccountSwitcherTarget: View, Equatable {
  static let size: Double = 48
  static let fontSize: Double = 12
  static let vStackSpacing: Double = 4
  static let floatOffsetVariationAmount: Double = 10
  static func == (lhs: AccountSwitcherTarget, rhs: AccountSwitcherTarget) -> Bool {
    lhs.account == rhs.account && lhs.hovered == rhs.hovered
  }
  
  @State private var floatOffset: CGSize = .zero
  @State private var timer = Timer.publish(every: 0.75, on: .main, in: .default).autoconnect()
  
  var hovered: Bool
  var account: RedditCredential
  var body: some View {
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
      .background(Circle().fill(Color.hex("F2DDFF")).blur(radius: 30))
      .background(Circle().fill(Color.hex("F2DDFF")).blur(radius: 20))
      .background(Circle().fill(Color.hex("F2DDFF")).blur(radius: 10))
      .background(Circle().fill(Color.hex("F2DDFF")).blur(radius: 5))
      .onReceive(timer) { _ in
        withAnimation(.smooth.speed(0.15)) {
          let range = (0-(Self.floatOffsetVariationAmount/2))...(0+(Self.floatOffsetVariationAmount/2))
          floatOffset = .init(width: .random(in: range), height: .random(in: range))
        }
      }
      Text(account.userName ?? "Unknown")
        .foregroundStyle(.white)
        .shadow(radius: 8, y: 4)
        .fontSize(Self.fontSize, .semibold)
    }
    .offset(hovered ? .zero : floatOffset)
    .brightness(hovered ? 0.5 : 0)
    .scaleEffect(hovered ? 1.2 : 1)
    .animation(hovered ? .snappy.speed(2) : .smooth, value: hovered)
    .onChange(of: hovered) { val in
      let impact = UIImpactFeedbackGenerator(style: val ? .rigid : .soft)
      impact.prepare()
      impact.impactOccurred()
    }
  }
}
