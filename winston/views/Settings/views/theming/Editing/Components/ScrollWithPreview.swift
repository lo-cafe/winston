//
//  ScrollWithPreview.swift
//  winston
//
//  Created by Igor Marcossi on 16/09/23.
//

import SwiftUI

private enum PreviewBG: String, CaseIterable {
  case blur, opaque, theme
}

struct ScrollWithPreview<Content: View, Preview: View>: View {
  var handlerBGOnly = false
  var theme: ThemeBG?
  @State private var previewBG: PreviewBG = .theme
  @State private var scrollOffset = CGFloat.zero
  @State private var contentSize = CGSize(width: 0, height: .screenH)
  @State private var previewContentSize: CGSize = .zero
  
  @Environment(\.tabBarHeight) private var tabBarHeight
  @Environment(\.colorScheme) private var cs
  @Environment(\.useTheme) private var currentTheme
  @ViewBuilder let content: () -> Content
  @ViewBuilder let preview: () -> Preview
    var body: some View {
      let tabHeight = CGFloat(tabBarHeight ?? 0)
      let interpolation = [
        -((.screenH - (tabHeight)) - ((contentSize.height + getSafeArea().top + tabHeight) - (previewContentSize.height + 40 + 16))),
         (contentSize.height + getSafeArea().top + tabHeight) - (.screenH - (getSafeArea().top)) - 20
      ]
      let interpolate = interpolatorBuilder(interpolation, value: scrollOffset)
      ObservedScrollView(offset: $scrollOffset, showsIndicators: false) {
        content()
          .padding(.bottom, previewContentSize.height + 40 + 16)
          .measure($contentSize)
      }
      .previewSheet(handlerBGOnly: handlerBGOnly, scrollContentHeight: contentSize.height, sheetContentSize: $previewContentSize, forcedOffset: interpolate([0, previewContentSize.height], false), bg: defaultBG.cs(cs).color(), border: currentTheme.lists.bg == theme && previewBG == .theme) { handlerHeight in
        VStack(spacing: 12) {
          let opts = [
            CarouselTagElement(label: "Blur", icon: { Image(systemName: "circle.dotted") }, value: PreviewBG.blur),
            CarouselTagElement(label: "Opaque", icon: { Image(systemName: "circle.fill") }, value: PreviewBG.opaque),
          ]
          TagsOptions($previewBG, options: opts + (theme == nil ? [] : [
            CarouselTagElement(label: "Theme", icon: {
              Circle().fill(.clear).themedListBG(theme!).frame(width: 16, height: 16).mask(Circle().fill(.black))
            }, value: PreviewBG.theme)
          ]))
          preview()
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.top, handlerHeight)
        .themedListBG(theme ?? defaultThemeBG, disable: theme == nil || previewBG != .theme)
        .background(
          previewBG != .blur
          ? nil
          : Rectangle().fill(Material.ultraThinMaterial).allowsHitTesting(false)
        )
        .background(
          previewBG != .opaque
          ? nil
          : defaultBG.cs(cs).color().allowsHitTesting(false)
        )
        
      }
    }
}
