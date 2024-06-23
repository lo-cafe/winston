//
//  Stars.swift
//  winston
//
//  Created by Igor Marcossi on 22/03/24.
//

import SwiftUI
import Defaults

private let starsCount = 7

struct SpaceAdventure: View {
  enum Phase: Int {
    case stars = 1
    case supernova = 2
    case blackhole = 3
  }
  
  @Binding private var shotComets: Int
  var totalWidth: CGFloat
  var comets: Int
  @Environment (\.colorScheme) private var colorScheme: ColorScheme
  @Default(.TipJarSettings) private var tipJarSettings
  @State private var phase: Phase = .stars
  @State private var stars: [ChildStarProps]
  
  init(shotComets: Binding<Int>, totalWidth: CGFloat, comets: Int) {
    self._shotComets = shotComets
    self.totalWidth = totalWidth
    self._stars = .init(initialValue: Array(0...(starsCount - 1)).map { ChildStarProps(starsCount: starsCount, index: $0, totalWidth: totalWidth) })
    self.comets = comets
  }
  
  var gradientColor: Color {
    return switch phase {
    case .blackhole, .stars: Color(uiColor: UIColor(light: UIColor(hex: "FFB13D"), dark: UIColor(hex: "FFCC02")))
    case .supernova: Color.hex("B3CDF6")
    }
  }
  
  func shootComet() -> Bool {
    if comets - shotComets > 0 {
      withAnimation(.spring) { shotComets += 1 }
      return true
    }
    return false
  }
  
  var body: some View {
    ZStack {
      switch phase {
      case .stars:
        ForEach(stars, id: \.self) { star in
          ChildStar(shootComet: shootComet, star: star, contentWidth: totalWidth)
        }
      case .supernova:
        Supernova(shootComet: shootComet)
          .offset(y: 80)
          .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 400)), removal: .scaleAndBlur))
      case .blackhole:
        Blackhole()
          .offset(y: 80)
          .transition(.identity)
      }
    }
    .onChange(of: shotComets) { _, val in
      if val == starsCount { doThisAfter(0.75) { withAnimation(.spring(response: 1, dampingFraction: 6)) { phase = .supernova } } }
      if val == starsCount * 2 { withAnimation(.spring(response: 1, dampingFraction: 2)) { phase = .blackhole } }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .opacity(1)
    .frame(maxWidth: .infinity, maxHeight: 200)
    .background(
      LinearGradient(gradient: Gradient(stops: generateGradientStops(gradientColor)), startPoint: .top, endPoint: .bottom)
        .frame(maxWidth: .infinity, maxHeight: colorScheme == .dark ? 175 : .infinity)
        .opacity(colorScheme == .dark ? 0.5 : 1)
      , alignment: .bottom
    )
//    .allowsHitTesting(false)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }
}
