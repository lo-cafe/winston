//
//  NiceDivider.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI

struct NiceDivider: View {
  var divider: LineTheme
    var body: some View {
      if divider.style == .fancy {
        VStack(spacing: 0) {
          Divider()
          divider.color()
            .frame(maxWidth: .infinity, minHeight: divider.thickness, maxHeight: divider.thickness)
          Divider()
        }
      } else if divider.style != .no {
        divider.color()
          .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
      }
    }
}
