//
//  Ribbon.swift
//  winston
//
//  Created by Igor Marcossi on 28/02/24.
//

import SwiftUI

#if DEBUG
private let ribbonImgName = "debugRibbon"
private let channelName = "Debug"
#elseif ALPHA
private let ribbonImgName = "alphaRibbon"
private let channelName = "Alpha"
#elseif BETA
private let ribbonImgName = "betaRibbon"
private let channelName = "Beta"
#else
private let ribbonImgName = ""
private let channelName = ""
#endif

struct Ribbon: View {
  @State private var step = 0
    var body: some View {
      if !ribbonImgName.isEmpty {
        HStack(alignment: .bottom, spacing: 8) {
          VStack(alignment: .trailing, spacing: 0) {
            Text(channelName).fontSize(22, .bold)
              .opacity(0.5)
            Text("Channel").fontSize(14, .medium)
              .opacity(0.25)
          }
          .compositingGroup()
          .offset(x: step < 2 ? 24 : 0)
          .opacity(step < 2 ? 0 : 1)
          .multilineTextAlignment(.trailing)
          .padding(.bottom, 16)
          .offset(y: -16)
          
          Image(ribbonImgName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 33, height: 150)
            .offset(y: step < 1 ? -158 : -16)
        }
        .padding(.trailing, 24)
        .onAppear {
          doThisAfter(0.5) {
            withAnimation(.bouncy(extraBounce: 0.05)) {
              step = 1
            } completion: {
              withAnimation(.bouncy(extraBounce: 0.05)) {
                step = 2
              }
            }
          }
        }
        .transition(.identity)
        .geometryGroup()
      }
    }
}
