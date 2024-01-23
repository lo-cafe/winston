//
//  ListRowBakground.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI

struct ThemedForegroundBG: View, Equatable {
  static func == (lhs: ThemedForegroundBG, rhs: ThemedForegroundBG) -> Bool {
    lhs.theme == rhs.theme && lhs.active == rhs.active && lhs.pressed == rhs.pressed && lhs.shiny == rhs.shiny
  }
  let theme: ThemeForegroundBG
  var active = false
  var pressed = false
  var shiny: Gradient? = nil
  var shadowStyle: ShadowStyle? = nil
  var body: some View {
    ThemedForegroundRawBG(shape: Rectangle(), theme: theme, active: active, pressed: pressed, shiny: shiny, shadowStyle: shadowStyle)
  }
}


struct ThemedForegroundRawBG<S: Shape>: View, Equatable {
  static func == (lhs: ThemedForegroundRawBG, rhs: ThemedForegroundRawBG) -> Bool {
    lhs.isInSidebar == rhs.isInSidebar && lhs.theme == rhs.theme && lhs.active == rhs.active && lhs.pressed == rhs.pressed && lhs.shiny == rhs.shiny
  }
  
  var shape: S
  let theme: ThemeForegroundBG
  var active = false
  var pressed = false
  var shiny: Gradient? = nil
  var shadowStyle: ShadowStyle? = nil
  @Environment(\.brighterBG) private var brighter
  @Environment(\.isInSidebar) private var isInSidebar
  var body: some View {
    let isActive = active && IPAD
    ZStack {
      if let shiny {
        shape.winstonShiny(shiny)
      } else {
        if theme.blurry {
          if let shadowStyle {
            shape.fill(.bar.shadow(shadowStyle))
          } else {
            shape.fill(.bar)
          }
        }
      }
      shape.fill(IPAD && isInSidebar && !brighter ? .clear : theme.color(brighter: !theme.blurry && brighter, brighterRatio: 0.075))
      
      
            
      shape.fill(Color.primary.opacity(pressed || (!IPAD && active) ? 0.1 : 0))
      
      if isActive { shape.fill(Color.accentColor) }
    }
    .clipShape(RoundedRectangle(cornerRadius: IPAD && isInSidebar ? 10 : 0, style: .continuous))
    .animation(active ? nil : .default.speed(2), value: active)
  }
}
