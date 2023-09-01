//
//  TipJar.swift
//  winston
//
//  Created by Igor Marcossi on 31/08/23.
//

import SwiftUI
import Defaults

struct TipJar: View {
  @Environment(\.openURL) private var openURL
  @Default(.showTipJarModal) private var showTipJarModal
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(spacing: 16) {
          Image("jar")
            .resizable()
            .scaledToFit()
            .frame(width: 56, height: 56)
            .padding(.all, 24)
            .background(Circle().fill(.blue.opacity(0.2)))
          
          VStack(spacing: 8) {
            Text("Now we got a tip jar!")
              .fontSize(24, .bold)
            
            Text("Many users wanted to be able to support the project without a monthly subscription (like Patreon), so now we got a tip jar!")
          }
        }
        MasterButton(img: "whiteJar", label: "Tip jar", colorHoverEffect: .animated, textSize: 18, height: 48, fullWidth: true, cornerRadius: 16) {
          openURL(URL(string: "https://ko-fi.com/locafe")!)
        }
        
        Text("It's also always available in the Settings tab :)")
        
      }
      
      .padding(.bottom, 128)
      .padding(.horizontal, 40)
      .padding(.top, 64)
    }
    .multilineTextAlignment(.center)
    .closeSheetBtn {
      withAnimation(spring) {
        showTipJarModal = false
      }
    }
  }
}

