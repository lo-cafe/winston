//
//  ThemeBGPicker.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import SwiftUI

struct ThemeBGPicker: View {
  @Binding var bg: ThemeBG
  var defaultVal: ThemeBG
  var body: some View {
    VStack {
      HStack {
        Text("BG type")
        
        Spacer()
        
        TagsOptions($bg, options: [CarouselTagElement<ThemeBG>(label: "Color", value: ThemeBG.color(defaultBG), active: bg.isEqual(.color(defaultBG))), CarouselTagElement<ThemeBG>(label: "Image", value: ThemeBG.img(listDefaultBGImage), active: bg.isEqual(.img(listDefaultBGImage)))])
      }
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity)
      .resetter($bg, .color(defaultBG))
      switch bg {
      case .color(let themeColor):
        SchemesColorPicker(theme: Binding(get: { themeColor }, set: { val, _ in
          bg = .color(val)
        }), defaultVal: defaultBG)
      case .img(let imgSchemes):
        SchemesBGImagesPicker(theme: Binding(get: { imgSchemes }, set: { val, _ in
          bg = .img(val)
        }), defaultVal: listDefaultBGImage)
      }
    }
    .mask(Rectangle().fill(.black))
  }
}

