//
//  ScrolViewContentRTLFriendly.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//

import SwiftUI

private struct ScrollViewContentRTLFriendly: ViewModifier {
    @Environment(\.layoutDirection) private var layoutDirection
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(Angle(degrees: layoutDirection == .rightToLeft ? -180 : 0), axis: (
                x: .zero,
                y: CGFloat(layoutDirection == .rightToLeft ? -10 : 0),
                z: .zero
            ))
    }
}

private struct ScrollViewRTLFriendly: ViewModifier {
    @Environment(\.layoutDirection) private var layoutDirection
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(Angle(degrees: layoutDirection == .rightToLeft ? 180 : 0), axis: (
                x: .zero,
                y: CGFloat(layoutDirection == .rightToLeft ? 10 : 0),
                z: .zero
            ))
    }
}

public extension View {
    func scrollViewContentRTLFriendly() -> some View {
        modifier(ScrollViewContentRTLFriendly())
    }
    func scrollViewRTLFriendly() -> some View {
        modifier(ScrollViewRTLFriendly())
    }
}
