//
//  BadgeSettings.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct BadgeSettings: View {
  @Binding var theme: BadgeTheme
  var defaultVal: BadgeTheme
  var showSub: Bool = false
    var body: some View {
      Group {
        
        FakeSection("Avatar") {
          Toggle("Show avatar", isOn: $theme.avatar.visible)
            .padding(.horizontal, 16)
          Divider()
          LabeledSlider(label: "Size", value: $theme.avatar.size, range: 8...64)
            .resetter($theme.avatar.size, defaultVal.avatar.size)
          Divider()
          LabeledSlider(label: "Corner radius", value: $theme.avatar.cornerRadius, range: 0...32)
            .resetter($theme.avatar.cornerRadius, defaultVal.avatar.cornerRadius)
          Divider()
          LabeledSlider(label: "Avatar Distance", value: $theme.spacing, range: 0...40)
            .resetter($theme.spacing, defaultVal.spacing)
        }
        
//        FakeSection(footer: "Currently subrredits show inline in a text accent-colored on the right of the author. With this option you can force it to always appear as a accent-colored tag instead.") {
//          Toggle("Force subs as tag", isOn: $theme.forceSubsAsTags)
//            .padding(.horizontal, 16)
//        }
        
        if (showSub) {
          FakeSection("Subreddit Color") {
            SchemesColorPicker(theme: $theme.subColor, defaultVal: defaultVal.subColor)
          }
        }
        
        FakeSection("Author font") {
          FontSelector(theme: $theme.authorText, defaultVal: defaultVal.authorText)
        }
        

          
        FakeSection("Flair font") {
          FontSelector(theme: $theme.flairText, defaultVal: defaultVal.flairText)
        }
        
        FakeSection("Flair Background") {
          SchemesColorPicker(theme: $theme.flairBackground, defaultVal: defaultVal.flairBackground)
        }
        
        FakeSection("Stats font") {
          FontSelector(theme: $theme.statsText, defaultVal: defaultTheme.posts.badge.statsText)
        }
        
      }
    }
}
