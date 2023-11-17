//
//  PaletteDisplayItem.swift
//  winston
//
//  Created by Daniel Inama on 23/10/23.
//

import SwiftUI
struct PaletteDisplayItem: View {
  var palette: [String]
  var name: String
  var body: some View {
    HStack{
      Text(name)
      Spacer()
      PaletteDisplayColor(colors: palette)
    }
    .tag(name)
    .padding(.horizontal)
  }
}
struct PaletteDisplayColor: View {
  var colors: [String]
  var body: some View {
    HStack{
      ForEach(colors, id: \.self){ color in
        Rectangle().fill().foregroundStyle(Color(uiColor: UIColor(hex: color))).clipShape(Circle()).frame(width: 10, height: 10)
      }

    }
  }
}
