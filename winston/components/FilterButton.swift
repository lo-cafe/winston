//
//  FlairButton.swift
//  winston
//
//  Created by Igor Marcossi on 18/12/23.
//

import SwiftUI

struct FilterButton: View, Equatable {
  static func == (lhs: FilterButton, rhs: FilterButton) -> Bool {
    lhs.filter == rhs.filter && lhs.isSelected == rhs.isSelected
  }
  
  var filter: FilterData
  var isSelected: Bool
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  var customFilterCallback: ((FilterData) -> ())
  let colorDotSize: Double = 8
  let hPadding: Double = 14
  let height: Double = 32
 let longPressDuration: Double = 0.275
  
//  @GestureState private var pressingDown = false
  @State private var pressingDown = false
  @State private var editTimer: Timer? = nil
  
  var body: some View {
    let isSelected = filter.type == "search" ? searchText.lowercased() == filter.text.lowercased() : isSelected
    let bgColor = Color.hex(filter.background_color)
    let brightness = bgColor.brightness()
    let contrastColor = brightness > 0.7 ? bgColor.darken(0.65) : bgColor.lighten(0.9)
    HStack(spacing: 6) {
      Image(systemName: "xmark")
        .fontSize(11, .semibold)
        .foregroundStyle(contrastColor)
        .scaleEffect(isSelected ? 1 : 0.01)
        .transaction { trans in
          trans.animation = .bouncy
        }

      Text(filter.getFormattedText())
        .fontSize(15, .medium)
        .foregroundColor(isSelected ? contrastColor : .primary)
    }
    .padding(.horizontal, hPadding)
    .frame(height: height)
    .background(alignment: .leading) {
      GeometryReader { geo in
        Circle()
          .fill(Color.hex(filter.background_color))
          .frame(width: geo.size.width, height: geo.size.width, alignment: .leading)
          .scaleEffect(isSelected ? 1 : colorDotSize / geo.size.width)
          .position(x: isSelected ? geo.size.width / 2 : hPadding + (colorDotSize / 2), y: height / 2)
          .transaction { trans in
            trans.animation = .snappy
          }
      }
      .frame(maxWidth: .infinity)
    }
    .clipShape(Capsule(style: .continuous))
    .drawingGroup()
    .floating()
    .scaleEffect(pressingDown ? 0.95 : 1)
    .animation(.bouncy(duration: 0.3, extraBounce: 0.225), value: pressingDown)
    .onTapGesture {
      Hap.shared.play(intensity: 0.5, sharpness: 0.5)
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
    .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 10, perform: {}, onPressingChanged: { val in
      pressingDown = val
      
      if val && filter.type != "flair" {
        editTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
          Hap.shared.play(intensity: 0.75, sharpness: 0.9)
          customFilterCallback(filter)
        }
      } else {
        editTimer?.invalidate()
      }
    })
  }
}
