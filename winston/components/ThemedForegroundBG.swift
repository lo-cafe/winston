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
  var shape: any Shape = Rectangle()
  var shadowStyle: ShadowStyle? = nil
  var body: some View {
    ThemedForegroundRawBG(shape: Rectangle(), theme: theme, active: active, pressed: pressed, shiny: shiny, shadowStyle: shadowStyle)
  }
}


struct ThemedForegroundRawBG<S: Shape>: View, Equatable {
  static func == (lhs: ThemedForegroundRawBG, rhs: ThemedForegroundRawBG) -> Bool {
    lhs.theme == rhs.theme && lhs.active == rhs.active && lhs.pressed == rhs.pressed && lhs.shiny == rhs.shiny
  }
  var shape: S
  let theme: ThemeForegroundBG
  var active = false
  var pressed = false
  var shiny: Gradient? = nil
  var shadowStyle: ShadowStyle? = nil
  @Environment(\.brighterBG) private var brighter
  var body: some View {
    let isActive = active && IPAD
    Group {
      ZStack {
        if shiny == nil {
          Group {
            if let shadowStyle {
              shape
                .fill(.bar.opacity(theme.blurry ? 1 : 0).shadow(shadowStyle)).allowsHitTesting(false)
            } else {
              shape
                .fill(.bar.opacity(theme.blurry ? 1 : 0))
            }
          }
          .overlay(shape.fill(isActive ? .accentColor : theme.color(brighter: !theme.blurry && brighter, brighterRatio: 0.075)))
        } else {
          Rectangle().winstonShiny(shiny)
        }
      }
    }
    .overlay(shape.fill(isActive ? Color.accentColor : .primary.opacity(pressed || (!IPAD && active) ? 0.1 : 0)).brightness(brighter ? 0.075 : 0).animation(.default.speed(2), value: active))
  }
}
