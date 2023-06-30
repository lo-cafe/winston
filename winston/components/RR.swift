//
//  RR.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//


import SwiftUI

struct FilledRoundedRectangle: View {
    let cornerRadius: CGFloat
    let fill: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fill)
    }
}

func RR(_ cornerRadius: CGFloat, _ fill: Color) -> FilledRoundedRectangle {
    return FilledRoundedRectangle(cornerRadius: cornerRadius, fill: fill)
}
