//
//  CredentialEditAssistantMode.swift
//  winston
//
//  Created by Igor Marcossi on 01/01/24.
//

import SwiftUI

struct CredentialEditAssistantMode: View {
  static let fabHeight: Double = 48
  static let fabMargin: Double = 12
  @State private var page = 0
    var body: some View {
      ZStack {
        GuidedTutorialScene()
      }
//      .navigationBarBackButtonHidden()
//      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//      .overlay(alignment: .bottomTrailing) {
//        PressableButton {
//          page += 1
//        } label: { pressed in
//          HStack(spacing: 12) {
//            Text("I've allowed the extension")
//              .fontSize(16, .semibold)
//            Image(systemName: "arrow.right")
//              .fontSize(20, .medium)
//          }
//          .foregroundStyle(Color.accentColor.antagonist(extreme: true))
//          .padding(.leading, 20)
//          .padding(.trailing, 16)
//          .frame(height: Self.fabHeight)
//          .background(Capsule(style: .continuous).fill(Color.accentColor).shadow(radius: 16))
//          .scaleEffect(pressed ? 0.95 : 1)
//          .onChange(of: pressed) {
//            Hap.shared.play(intensity: $0 ? 0.75 : 1, sharpness: $0 ? 0.85 : 1)
//          }
//        }
//        .padding(.all, Self.fabMargin)
//
//      }
    }
}
