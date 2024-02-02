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
  
  var filter: ShallowCachedFilter
  var isSelected: Bool
  var selectFilter: (ShallowCachedFilter) -> ()
  
  private let colorDotSize: Double = 8
  private let hPadding: Double = 14
  private let height: Double = 32
  private let longPressDuration: Double = 0.275
  
  //  @GestureState private var pressingDown = false
  @State private var pressingDown = false
  @State private var editTimer: Timer? = nil
  
  var body: some View {
//    let isSelected = filter.type == "search" ? searchText.lowercased() == filter.text.lowercased() : isSelected
    let bgColor = Color.hex(filter.bgColor ?? "FFFFFF")
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
      
      Text(filter.text)
        .fontSize(15, .medium)
        .foregroundColor(isSelected ? contrastColor : .primary)
    }
    .padding(.horizontal, hPadding)
    .frame(height: height)
    .background(alignment: .leading) {
      GeometryReader { geo in
        Circle()
          .fill(bgColor)
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
      selectFilter(filter)
    }
//    .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 10, perform: {}, onPressingChanged: { val in
//      pressingDown = val
//      
//      if val && filter.type != "flair" {
//        editTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
//          Hap.shared.play(intensity: 0.75, sharpness: 0.9)
//          customFilterCallback(filter)
//        }
//      } else {
//        editTimer?.invalidate()
//      }
//    })
  }
}
