//
//  WDivider.swift
//  winston
//
//  Created by Igor Marcossi on 02/08/23.
//

import SwiftUI

struct WDivider: View {
    var body: some View {
      Rectangle()
        .fill(.primary.opacity(0.05))
        .frame(maxWidth: .infinity, maxHeight: 1)
        .allowsHitTesting(false)
    }
}
