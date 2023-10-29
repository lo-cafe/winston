//
//  RR.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//


import SwiftUI
import SwiftUIX

struct FilledRoundedRectangle<S: ShapeStyle>: View, Equatable {
  static func == (lhs: FilledRoundedRectangle, rhs: FilledRoundedRectangle) -> Bool {
    lhs.cornerRadius == rhs.cornerRadius
  }
  
    let cornerRadius: CGFloat
    let fill: S
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(fill)
    }
}

func RR<S: ShapeStyle>(_ cornerRadius: CGFloat, _ fill: S) -> FilledRoundedRectangle<S> {
    return FilledRoundedRectangle(cornerRadius: cornerRadius, fill: fill)
}
