//
//  ThemeSettings.swift
//  winston
//
//  Created by Daniel Inama on 25/08/23.
//

import SwiftUI
import Defaults

struct ThemeSettings: View {
  @Default(.arrowDividerColorPalette) var arrowDividerColorPalette
  @Default(.winstonCommentAccentStyle) var winstonCommentAccentStyle
  
  var body: some View {
    List{
      Section("Comments"){
        Picker("Comment Accent Style", selection: Binding(get: {
          winstonCommentAccentStyle ? "Winston" : "Apollo"
        }, set: {val, _ in
          winstonCommentAccentStyle = val == "Winston"
        })){
          Text("Winston").tag("Winston")
          Text("Apollo").tag("Apollo")
       }
        
        Picker("Comments Theme", selection: Binding(get: {
          arrowDividerColorPalette
        }, set: { val, _ in
          arrowDividerColorPalette = val
        })){
          PaletteDisplayItem(palette: ArrowColorPalette.monochrome, name: "Monochrome")
          PaletteDisplayItem(palette: ArrowColorPalette.rainbow, name: "Rainbow")
          PaletteDisplayItem(palette: ArrowColorPalette.ibm, name: "IBM")
          PaletteDisplayItem(palette: ArrowColorPalette.fire, name: "Fire")
          PaletteDisplayItem(palette: ArrowColorPalette.forest, name: "Forest")
          PaletteDisplayItem(palette: ArrowColorPalette.ocean, name: "Ocean")
        }
        .pickerStyle(.inline)
      }
    }
    .navigationTitle("Themes")
    .navigationBarTitleDisplayMode(.inline)
  }
}

