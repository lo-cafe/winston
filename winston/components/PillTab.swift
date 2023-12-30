//
//  PillTab.swift
//  winston
//
//  Created by Igor Marcossi on 25/07/23.
//

import SwiftUI

struct PillTab: View {
    var icon: String
    var label: String
    var active: Bool
    var onPress: (() -> Void)?
    var body: some View {
        Button {
            onPress?()
        } label: {
            HStack{
                Group {
                    Text(icon)
                    if active {
                        Text(label)
                    }
                }
                .opacity(0.9)
            }
            .compositingGroup()
            .frame(alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .cornerRadius(100)
            .clipped()
            .saturation(active ? 1 : 0)
            .opacity(active ? 1 : 0.5)
            .background(
              Capsule(style: .continuous)
                  .strokeBorder(.white.opacity(0.05), lineWidth: 0.5)
            )
            .background(
              Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 6)
            )
//            .background(
//                Capsule()
//                  .stroke(.black.opacity(0.2), lineWidth: 0.5)
//            )

        }
        .buttonStyle(NoBtnStyle())
        .shrinkOnTap()
        .disabled(active)
    }
}
