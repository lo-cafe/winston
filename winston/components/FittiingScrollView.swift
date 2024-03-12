//
//  FittiingScrollView.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//

import SwiftUI

/// Source: https://github.com/shaps80/SwiftUIBackports
/// A scrollview that behaves more similarly to a `VStack` when its content size is small enough.
public struct FittingScrollView<Content: View>: View {
    private let content: Content
    let onOffsetChange: ((CGFloat) -> Void)?

    public init(@ViewBuilder content: () -> Content, onOffsetChange: ((CGFloat) -> Void)? = nil) {
        self.content = content()
        self.onOffsetChange = onOffsetChange
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollViewOffset {
                onOffsetChange?($0)
            } content: {
                VStack {
                    content
                }.frame(maxWidth: geo.size.width, minHeight: geo.size.height)
            }
        }
    }
}

// Source: https://www.fivestars.blog/articles/scrollview-offset/
public struct ScrollViewOffset<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    
    public init(
        onOffsetChange: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onOffsetChange = onOffsetChange
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            offsetReader
            content()
                .padding(.top, -8)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
    }
    
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).minY
                )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
