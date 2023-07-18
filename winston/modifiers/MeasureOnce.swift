//
//  MeasureOnce.swift
//  winston
//
//  Created by Igor Marcossi on 17/07/23.
//

import Foundation
import SwiftUI

extension View {
    func measureOnce(_ size: Binding<CGSize>) -> some View {
        return self.background(GeometryReader { geometry in
            Color.clear.onAppear {
              if size.wrappedValue == .zero {
                    DispatchQueue.main.async {
                        size.wrappedValue = geometry.size
                    }
                }
            }
        })
    }
}
