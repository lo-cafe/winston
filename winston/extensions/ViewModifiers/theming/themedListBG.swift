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
  
  func updateImg(_ bg: ThemeBG, _ cs: ColorScheme) {
    uiImage = returnImg(bg: bg, cs: cs)
  }
  
  func body(content: Content) -> some View {
    let actuallyBrighter = brighter && !forceNonBrighter
    content
      .scrollContentBackground(.hidden)
      .onAppear {
        updateImg(bg, cs)
      }
      .onChange(of: bg) { _, val in
        updateImg(val, cs)
      }
      .onChange(of: cs) { _, val in
        updateImg(bg, val)
      }
      .background {
        if let uiImage, !disable {
          GeometryReader { geo in
            Image(uiImage: uiImage)
              .antialiased(true).resizable()
              .aspectRatio(contentMode: .fill)
              .saturation(!actuallyBrighter ? 1 : 0.75)
              .contrast(!actuallyBrighter ? 1 : 0.6)
              .brightness(!actuallyBrighter ? 0 : cs == .dark ? 0.25 : 0)
              .frame(width: geo.size.width, height: geo.size.height)
          }.edgesIgnoringSafeArea(.all).allowsHitTesting(false)
        }
      }
      .background {
        if !disable && uiImage == nil {
          GeometryReader { geo in
            returnColor(bg: bg, cs: cs, brighter: actuallyBrighter)
              .frame(width: geo.size.width, height: geo.size.height)
          }.edgesIgnoringSafeArea(.all).allowsHitTesting(false)
        }
      }
  }
}

extension View {
  func themedListBG(_ bg: ThemeBG, disable: Bool = false, forceNonBrighter: Bool = false) -> some View {
    self.modifier(ThemedListBGModifier(bg: bg, disable: disable, forceNonBrighter: forceNonBrighter))
  }
}

private func returnColor(bg: ThemeBG, cs: ColorScheme, brighter: Bool) -> Color {
  switch bg {
  case .color(let color):
    return color(brighter: brighter)
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
