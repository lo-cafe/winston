//
//  getInitialSize.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import SwiftUI

struct GetInitialSizeModifier: ViewModifier {
    @Binding var size: CGSize
    @State private var sizeSet: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if !sizeSet {
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                size = geometry.size
                                sizeSet = true
                            }
                        }
                    } else {
                        Color.clear
                    }
                }
            )
    }
}

extension View {
    func getInitialSize(_ size: Binding<CGSize>) -> some View {
        self.modifier(GetInitialSizeModifier(size: size))
    }
}
