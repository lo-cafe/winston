//
//  BigInfoCredential.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

struct BigInfoCredential: View {
  var label: String
  var value: String?
  var refresh: (() async -> ())? = nil
  @State private var copied = false
  @State private var refreshed = false
  @State private var bounce = 0
  @State private var spin = false
  @State private var loading = false
  var body: some View {
    let empty = value == nil || (value?.isEmpty ?? false)
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .bottom) {
        Text(label).fontSize(20, .semibold)
        
        Spacer()
        
        HStack(spacing: 12) {
          
          Button {
            UIPasteboard.general.string = value
            withAnimation(.bouncy) { copied = true; bounce += 1 }
            doThisAfter(0.3) { withAnimation { copied = false } }
          } label: {
            Image(systemName: "doc.on.clipboard")
              .symbolRenderingMode(.hierarchical)
              .brightness(copied ? 0.2 : 0)
              .ifIOS17({ img in
                if #available(iOS 17, *) {
                  img
                    .symbolEffect(.bounce, value: bounce)
                }
              })
          }
          
          if let refresh = refresh {
            Button {
              withAnimation(.bouncy) { refreshed = true; spin = true }
              doThisAfter(0.3) { refreshed = false }
              doThisAfter(0.5) { spin = false }
              withAnimation { loading = true }
              Task(priority: .background) {
                await refresh()
                await MainActor.run { withAnimation { loading = false } }
              }
            } label: {
              Image(systemName: "arrow.clockwise")
                .brightness(copied ? 0.2 : 0)
                .rotationEffect(.degrees(spin ? 360 : 0))
            }
          }
          
        }
        .fontSize(16, .semibold)
        .foregroundStyle(Color.accentColor)
        .allowsHitTesting(!empty)
        .saturation(empty ? 0 : 1)
      }
      Text(empty ? "Empty" : value).opacity(0.5)
        .fontSize(12, .medium, design: .monospaced)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .blur(radius: loading ? 24 : 0)
        .overlay {
          !loading
          ? nil
          : ProgressView()
        }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .mask(RR(16, .black))
    .background(RR(16, Color("acceptableBlack")))
    .scrollDismissesKeyboard(.interactively)
  }
}
