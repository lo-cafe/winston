//
//  themedListBG.swift
//  winston
//
//  Created by Igor Marcossi on 08/09/23.
//

import SwiftUI

struct ThemedListBGModifier: ViewModifier {
  var bg: ThemeBG
  var disable = false
  var forceNonBrighter = false
  
  @Environment(\.colorScheme) private var cs
  @Environment(\.brighterBG) private var brighter
  @State private var uiImage: UIImage?
  
  func updateImg(_ bg: ThemeBG) {
    uiImage = returnImg(bg: bg, cs: cs)
  }

  func body(content: Content) -> some View {
    content
      .onAppear {
        updateImg(bg)
      }
      .onChange(of: bg) { val in
        updateImg(val)
      }
      .background(disable ? nil : GeometryReader { geo in returnColor(bg: bg, cs: cs).brightness(brighter && !forceNonBrighter ? 0.11 : 0).frame(width: geo.size.width, height: geo.size.height) }.edgesIgnoringSafeArea(.all).allowsHitTesting(false))
      .background(disable ? nil : GeometryReader { geo in Image(uiImage: uiImage).antialiased(true).resizable().scaledToFill().frame(width: geo.size.width, height: geo.size.height) }.edgesIgnoringSafeArea(.all).allowsHitTesting(false))
      .scrollContentBackground(.hidden)
  }
}

extension View {
  func themedListBG(_ bg: ThemeBG, disable: Bool = false, forceNonBrighter: Bool = false) -> some View {
    self.modifier(ThemedListBGModifier(bg: bg, disable: disable, forceNonBrighter: forceNonBrighter))
  }
}

private func returnColor(bg: ThemeBG, cs: ColorScheme) -> Color {
  switch bg {
  case .color(let color):
    return color.cs(cs).color()
  default:
    return Color.clear
  }
}

private func returnImg(bg: ThemeBG, cs: ColorScheme) -> UIImage? {
  switch bg {
  case .img(let img):
      return loadImage(fileName: img.cs(cs))
  default:
    return nil
  }
}
