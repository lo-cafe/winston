//
//  NiceDivider.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI

struct NiceDivider: View {
  var divider: LineTheme
  @Environment(\.colorScheme) private var cs
    var body: some View {
      if divider.style == .fancy {
        VStack(spacing: 0) {
          Divider()
          divider.color.cs(cs).color()
            .frame(maxWidth: .infinity, minHeight: divider.thickness, maxHeight: divider.thickness)
          Divider()
        }
      } else if divider.style != .no {
        divider.color.cs(cs).color()
          .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
      }
    }
}
