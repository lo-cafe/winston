//
//  postFontSettings.swift
//  winston
//
//  Created by Daniel Inama on 19/08/23.
//

import SwiftUI
import Defaults

struct postFontSettings: View {
  @Default(.postLinkTitleSize) var postLinkTitleSize
  @Default(.postLinkBodySize) var postLinkBodySize
  @Default(.postViewTitleSize) var postViewTitleSize
  @Default(.postViewBodySize) var postViewBodySize
  @Default(.compactMode) var compactMode

    var body: some View {
      List{
        VStack(alignment: .leading) {
          HStack {
            Text("Post Link Title Size")
            Spacer()
            Text("\(Int(postLinkTitleSize))")
              .opacity(0.6)
              .fontSize(postLinkTitleSize, .medium)
          }
          Slider(value: $postLinkTitleSize, in: 10...32, step: 1)
        }
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post Link Body Size")
            Spacer()
            Text("\(Int(postLinkBodySize))")
              .opacity(0.6)
              .fontSize(postLinkBodySize)
          }
          Slider(value: $postLinkBodySize, in: 10...32, step: 1)
        }
        .disabled(compactMode)
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post Page Title Size")
            Spacer()
            Text("\(Int(postViewTitleSize))")
              .opacity(0.6)
              .fontSize(postViewTitleSize, .semibold)
          }
          Slider(value: $postViewTitleSize, in: 10...32, step: 1)
        }
        
        VStack(alignment: .leading) {
          HStack {
            Text("Post Page Body Size")
            Spacer()
            Text("\(Int(postViewBodySize))")
              .opacity(0.6)
              .fontSize(postViewBodySize)
          }
          Slider(value: $postViewBodySize, in: 10...32, step: 1)
        }
      }
    }
}

