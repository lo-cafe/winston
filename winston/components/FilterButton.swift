//
//  FlairButton.swift
//  winston
//
//  Created by Igor Marcossi on 18/12/23.
//

import SwiftUI

struct FilterButton: View {
  var filter: FilterData
  var isSelected: Bool
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  
  var body: some View {
    let isSelected = filter.type == "search" ? searchText.lowercased() == filter.text.lowercased() : isSelected
    let bgColor = Color.hex(filter.background_color)
    let brightness = bgColor.brightness()
    let contrastColor = brightness > 0.7 ? bgColor.darken(0.65) : bgColor.lighten(0.9)
    HStack(spacing: 6) {
      Circle()
        .fill(contrastColor)
        .frame(width: 8, height: 8)
        .scaleEffect(isSelected ? 1 : 0.01)
        .transaction { trans in
          trans.animation = .bouncy
        }
      Text(filter.text)
        .fontSize(15, .medium)
        .foregroundColor(isSelected ? contrastColor : .primary)
    }
    .padding(.horizontal, 14)
    .frame(height: 32)
    .background(alignment: .leading) {
      GeometryReader { geo in
        Circle()
          .fill(Color.hex(filter.background_color))
          .frame(width: isSelected ? geo.size.width : 8, height: isSelected ? geo.size.width : 8, alignment: .leading)
          .position(x: isSelected ? geo.size.width / 2 : 14, y: 16)
          .transaction { trans in
            trans.animation = .snappy
          }
      }
      .frame(maxWidth: .infinity)
    }
    .mask { Capsule().fill(.black) }
    .floating()
    .scaleEffect(1)
    .onTapGesture {
      if filter.type == "search" {
        if searchText != filter.text {
          searchCallback(filter.text)
        } else {
          searchCallback(nil)
        }
      } else {
        filterCallback(isSelected ? "flair:All" : filter.id)
      }
    }
  }
}
