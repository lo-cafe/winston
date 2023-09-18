//
//  ObservedScrollView.swift
//  winston
//
//  Created by Igor Marcossi on 27/06/23.
//

import Foundation
import SwiftUI

struct ObservedScrollView<Content: View>: View {
    @Binding var offset: CGFloat
    var showsIndicators = true
    let content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            VStack {
                content()
            }
            .background(GeometryReader {
                Color.clear.preference(key: ViewOffsetKey.self,
                    value: -$0.frame(in: .named("scroll")).origin.y)
            })
            .onPreferenceChange(ViewOffsetKey.self) {
                offset = $0
            }
        }
        .coordinateSpace(name: "scroll")
     }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
