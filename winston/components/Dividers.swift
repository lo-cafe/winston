//
//  Dividers.swift
//  winston
//
//  Created by Igor Marcossi on 15/09/23.
//

import SwiftUI

struct VDivider: View {
  @Environment(\.colorScheme) private var cs
  @Environment(\.useTheme) private var currentTheme
    var body: some View {
      Rectangle()
        .fill(currentTheme.lists.dividersColors.cs(cs).color())
        .frame(maxWidth: 0.5, maxHeight: .infinity)
    }
}

struct HDivider: View {
  @Environment(\.colorScheme) private var cs
  @Environment(\.useTheme) private var currentTheme
    var body: some View {
      Rectangle()
        .fill(currentTheme.lists.dividersColors.cs(cs).color())
        .frame(maxWidth: .infinity, maxHeight: 0.5)
    }
}
