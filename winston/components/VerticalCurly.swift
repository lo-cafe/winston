//
//  VerticalCurly.swift
//  winston
//
//  Created by Igor Marcossi on 01/03/24.
//

import SwiftUI

struct VerticalCurly: View {
  var offset: Double = 0
  @State private var innerSize: CGSize = .zero
  var body: some View {
    //      VStack(alignment: .center, spacing: -2) {
    VStack(alignment: .center, spacing: 0) {
      Image(.startCurly).resizable().scaledToFit().frame(width: 7, height: 23)
//      let intArray: [Int] = Array(1...(innerSize == .zero ? 2 : Int(floor((innerSize.height - 37) / 14))))
//      ForEach(intArray, id: \.self) { i in
//        Image(.middleCurly).resizable().scaledToFit().frame(width: 6, height: 14)
//      }
      Image(.endCurly).resizable().scaledToFit().frame(width: 6, height: 14)
    }
    .fixedSize(horizontal: false, vertical: true)
    //      .animation(.spring) { v in
    .frame(height: innerSize == .zero ? 0 : innerSize.height, alignment: .top)
    .clipped()
    //      }
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color.blue.measure($innerSize))
//    .measure($innerSize, disable: innerSize != .zero)
    .clipped()
    .transition(.identity)
  }
}
