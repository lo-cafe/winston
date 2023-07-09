//
//  Arrows.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI

struct Arrows: View {
  var disableShapeShift: Bool
    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        CornerShape()
          .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
          .frame(maxWidth: 12, maxHeight: .infinity)
      }
      .padding(.leading, 1)
      .padding(.bottom, 1)
      .offset(y: disableShapeShift ? 0 : -12)
      .padding(.top, disableShapeShift ? 0 : -12 - 8)
      .padding(.bottom, disableShapeShift ? 12 : 0)
      .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

//struct Arrows_Previews: PreviewProvider {
//    static var previews: some View {
//        Arrows()
//    }
//}
