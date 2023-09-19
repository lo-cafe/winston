//
//  CardSettings.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct CardSettings: View {
  @Binding var theme: PostLinkTheme
  @State var asas = "askmo"
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
            EmptyView()
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
