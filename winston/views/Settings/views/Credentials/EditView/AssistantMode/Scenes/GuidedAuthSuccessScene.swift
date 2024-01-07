//
//  GuidedAuthSuccessScene.swift
//  winston
//
//  Created by Igor Marcossi on 06/01/24.
//

import SwiftUI

struct GuidedAuthSuccessScene: View {
  let draftCredential: RedditCredential
  var body: some View {
    VStack(spacing: 40) {
      VStack(spacing: 8) {
        BetterLottieView("party-appear", size: 128, skipInitialProgress: 0.02, color: nil)
        VStack(spacing: 4) {
        Text("Sweeeet!").fontSize(32, .bold)
        Text("Everything went well. You can start using Winston now!").opacity(0.9)
      }
      }
      VStack(spacing: 16) {
        WinstonButton {
          Hap.shared.play(intensity: 0.75, sharpness: 0.5)
          doThisAfter(0.1) { Hap.shared.play(intensity: 0.9, sharpness: 1) }
          draftCredential.save()
          Nav.present(nil)
        } label: {
          Label("Save and let's rock!", systemImage: "balloon.fill")
        }
      }
    }
    .multilineTextAlignment(.center)
    .overlay(alignment: .top) {
      BetterLottieView("confetti-magic", size: .screenW, initialDelay: 0.1, color: nil)
        .padding(.top, -176)
        .allowsHitTesting(false)
    }
    .padding(EdgeInsets(top: 64, leading: 32, bottom: 0, trailing: 32))
    .frame(maxHeight: .infinity, alignment: .top)
    .onAppear {
      Task {
        // SHAME ON ME FOR THIS PROFANITY BELOW
        // but I wasn't into learning .haap files syntax
        // nor modifiying my haptics class lol
        // but it works... so.........
        doThisAfter(0.1) {
        Hap.shared.play(intensity: 1, sharpness: 0.85)
        doThisAfter(0.5) {
          Hap.shared.play(intensity: 0.35, sharpness: 1)
          doThisAfter(0.03) {
            Hap.shared.play(intensity: 0.35, sharpness: 1)
          }
          doThisAfter(0.145) {
            Hap.shared.play(intensity: 0.55, sharpness: 1)
          }
          doThisAfter(0.15) {
            Hap.shared.play(intensity: 0.45, sharpness: 1)
          }
          doThisAfter(0.2) {
            Hap.shared.play(intensity: 0.45, sharpness: 1)
          }
          doThisAfter(0.215) {
            Hap.shared.play(intensity: 0.25, sharpness: 1)
          }
          doThisAfter(0.24) {
            Hap.shared.play(intensity: 0.45, sharpness: 1)
          }
          doThisAfter(0.245) {
            Hap.shared.play(intensity: 0.35, sharpness: 1)
          }
          doThisAfter(0.55) {
            Hap.shared.play(intensity: 0.75, sharpness: 1)
          }
          doThisAfter(0.75) {
            Hap.shared.play(intensity: 0.45, sharpness: 1)
          }
          doThisAfter(0.85) {
            Hap.shared.play(intensity: 0.65, sharpness: 1)
          }
          doThisAfter(1.1) {
            Hap.shared.play(intensity: 0.5, sharpness: 1)
          }
        }
        }
      }
    }
//    .overlay {
//      GeometryReader { g in
//        BetterLottieView("confetti", size: g.size, color: nil, contentMode: .fill)
//      }.ignoresSafeArea(.all)
//    }
  }
}
