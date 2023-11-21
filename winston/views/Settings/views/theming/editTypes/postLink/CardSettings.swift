//
//  CardSettings.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct CardSettings: View {
  @Binding var theme: PostLinkTheme
  var body: some View {
    Group {
      
      FakeSection("Spacing") {
        LabeledSlider(label: "Inner horizontal padding", value: $theme.innerPadding.horizontal, range: 0...64)
          .resetter($theme.innerPadding.horizontal, defaultTheme.postLinks.theme.innerPadding.horizontal)
        Divider()
        LabeledSlider(label: "Inner vertical padding", value: $theme.innerPadding.vertical, range: 0...64)
          .resetter($theme.innerPadding.vertical, defaultTheme.postLinks.theme.innerPadding.vertical)
        Divider()
        LabeledSlider(label: "Outer horizontal padding", value: $theme.outerHPadding, range: 0...64)
          .resetter($theme.outerHPadding, defaultTheme.postLinks.theme.outerHPadding)
        Divider()
        LabeledSlider(label: "Elements distance", value: $theme.verticalElementsSpacing, range: 0...64)
          .resetter($theme.verticalElementsSpacing, defaultTheme.postLinks.theme.verticalElementsSpacing)
        Divider()
      }
      
      FakeSection("Media") {
        
        LabeledSlider(label: "Media corner radius", value: $theme.mediaCornerRadius, range: 0...64)
          .resetter($theme.mediaCornerRadius, defaultTheme.postLinks.theme.mediaCornerRadius)
        
        Divider()
        
        VStack(alignment: .leading, spacing: 8) {
          Text("Placeholder image")
          
          HStack(spacing: 2) {
            Image(.winstonFlat)
              .resizable()
              .aspectRatio(1, contentMode: .fit)
              .frame(height: 24)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(RR(8, .primary.opacity(theme.compactSelftextPostLinkPlaceholderImg.type == .winston ? 0.1 : 0)))
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(.default.speed(2)) {
                  theme.compactSelftextPostLinkPlaceholderImg.type = .winston
                }
              }
            Image(systemName: "square.text.square")
              .fontSize(24)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(RR(8, .primary.opacity(theme.compactSelftextPostLinkPlaceholderImg.type == .icon ? 0.1 : 0)))
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(.default.speed(2)) {
                  theme.compactSelftextPostLinkPlaceholderImg.type = .icon
                }
              }
          }
          .foregroundStyle(.primary.opacity(0.5))
          .frame(height: 48)
          .resetter($theme.compactSelftextPostLinkPlaceholderImg.type, defaultTheme.postLinks.theme.compactSelftextPostLinkPlaceholderImg.type)
          
          SchemesColorPicker(theme: $theme.compactSelftextPostLinkPlaceholderImg.color, defaultVal: defaultTheme.postLinks.theme.compactSelftextPostLinkPlaceholderImg.color)
        }
        .padding(.horizontal, 16)
      }
      
      
      FakeSection("Card") {
        LabeledSlider(label: "Corner radius", value: $theme.cornerRadius, range: 0...64)
          .resetter($theme.cornerRadius, defaultTheme.postLinks.theme.cornerRadius)
        
        Divider()
        
        ThemeForegroundEdit(theme: $theme.bg, defaultVal: defaultTheme.postLinks.theme.bg)
        
        Divider()
        
        VStack {
          HStack {
            Text("Unseen type")
            
            Spacer()
            
            TagsOptions(
              $theme.unseenType,
              options: [
                CarouselTagElement<UnseenType>(
                  label: "Dot",
                  value: UnseenType.dot(.init(light: .init(hex: "4FFF85"), dark: .init(hex: "4FFF85"))),
                  active: theme.unseenType.isEqual(.dot(.init(light: .init(hex: "4FFF85"), dark: .init(hex: "4FFF85"))))
                ),
                CarouselTagElement<UnseenType>(label: "Fade", value: UnseenType.fade, active: theme.unseenType.isEqual(.fade))
              ]
            )
          }
          .padding(.horizontal, 16)
          .resetter($theme.unseenType, defaultTheme.postLinks.theme.unseenType)
          .frame(maxWidth: .infinity)
          
          switch theme.unseenType {
          case .dot(let themeColor):
            SchemesColorPicker(theme: Binding(get: { themeColor }, set: { val, _ in
              theme.unseenType = .dot(val)
            }), defaultVal: .init(light: .init(hex: "4FFF85"), dark: .init(hex: "4FFF85")))
          case .fade:
            LabeledSlider(label: "Fade Opacity", value: $theme.unseenFadeOpacity, range: 0...1, step: 0.01)
              .resetter($theme.unseenFadeOpacity, defaultTheme.postLinks.theme.unseenFadeOpacity)
          }
          
        }
        .mask(Rectangle().fill(.black))
        
      }
      
      FakeSection("Sticky posts") {
        LineThemeEditor(theme: $theme.stickyPostBorderColor, defaultVal: defaultTheme.postLinks.theme.stickyPostBorderColor)
      }
      
    }
    .animation(.default, value: theme.unseenType)
  }
}
