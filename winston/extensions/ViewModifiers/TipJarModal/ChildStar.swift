//
//  ChildStar.swift
//  winston
//
//  Created by Igor Marcossi on 22/03/24.
//

import SwiftUI
import Combine

struct ChildStarProps: Identifiable, Hashable {
  static func == (lhs: ChildStarProps, rhs: ChildStarProps) -> Bool {
    lhs.id == rhs.id && lhs.position == rhs.position
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
    hasher.combine(self.position)
  }
  
  let id = UUID()
  var position: CGPoint
  let size = CGFloat.random(in: 10...25)
  let duration: CGFloat
  
  init(starsCount: Int, index: Int, totalWidth: CGFloat) {
    let duration = CGFloat.random(in: 1.25...2)
    self.position = CGPoint(x: (((totalWidth - 48) / CGFloat(starsCount - 1)) * CGFloat(index)) + 24 + (CGFloat.random(in: 0...24) * ([-1, 1].randomElement())!), y: 200 + 42)
    self.duration = duration
  }
}

struct ChildStar: View {
  var shootComet: () -> Bool
  var contentWidth: Double
  @State private var star: ChildStarProps
  @State private var rotation: CGFloat = 180
  @State private var offset = CGFloat.random(in: 8...16) * ([-1, 1].randomElement())!
  @State private var timer = Timer.publish(every: 10, on: .current, in: .common).autoconnect()
  @State private var dead = false
  @Environment (\.colorScheme) var colorScheme: ColorScheme
  
  init(shootComet: @escaping () -> Bool, star: ChildStarProps, contentWidth: Double) {
    self.shootComet = shootComet
    self.contentWidth = contentWidth
    self._star = .init(initialValue: star)
  }
  
  func move() {
    offset = offset == 0 ? CGFloat.random(in: 8...16) : 0
    rotation = CGFloat.random(in: -20...20)
  }
  
  var body: some View {
    Image(systemName: "star.fill")
      .resizable()
      .scaledToFit()
      .frame(star.size)
    //            .foregroundColor(Color(NSColor(hex: colorScheme == .dark ? "F9EFBA" : "fafafa")))
      .foregroundColor(Color.hex(colorScheme == .dark ? "F9EFBA" : "7B733C"))
      .rotationEffect(Angle(degrees: dead ? 600 : rotation))
    //            .shadow(color: Color(NSColor(hex: colorScheme == .dark ? "FFA262" : "656565")), radius: size * 0.75, y: colorScheme == .dark ? 0 : size * 0.5)
      .shadow(color: Color.hex(colorScheme == .dark ? "FFA262" : "A9A400"), radius: star.size * 0.75, y: colorScheme == .dark ? 0 : star.size * 0.5)
      .shadow(color: Color.hex(colorScheme == .dark ? "FFA262" : "A9A400").opacity(0.75), radius: star.size * 1.25, y: colorScheme == .dark ? 0 : star.size * 0.5)
      .frame(25)
      .contentShape ( Rectangle() )
      .offset(x: dead ? (contentWidth / 2) - star.position.x : 0, y: dead ? 200 : offset)
      .position(star.position)
      .onReceive(timer) { _ in
        withAnimation(.easeInOut(duration: star.duration)) {
          move()
        }
      }
      .onAppear {
        timer.upstream.connect().cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + CGFloat.random(in: 0...0.75)) {
          withAnimation(.spring(response: CGFloat.random(in: 0.5...0.7), dampingFraction: 2)) {
            timer = Timer.publish(every: star.duration, on: .current, in: .common).autoconnect()
            star.position.y = CGFloat.random(in: 65.0...CGFloat(200 - Int(star.size) - 30))
            move()
          }
        }
      }
      .onTapGesture {
        if dead || !shootComet() { return }
        Hap.shared.play(intensity: 1, sharpness: 0.35)
        doThisAfter(0.1) {
          Hap.shared.play(intensity: 0.5, sharpness: 1)
        }
        withAnimation(.easeIn) {
          dead = true
        }
        timer.upstream.connect().cancel()
      }
      .allowsHitTesting(!dead)
      .onDisappear { timer.upstream.connect().cancel() }
      .id(star.id)
  }
}

