//
//  EndOfFeedView.swift
//  winston
//
//  Created by Ethan Bills on 11/21/23.
//

import SwiftUI

struct EndOfFeedView: View {
  @State private var tapCount = 0
  @State private var showAlert = false

  var body: some View {
    ZStack {
      Image("winstonEOF")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .onTapGesture {
          self.handleTap()
        }

      Text(QuirkyMessageUtil.quirkyEndOfFeed())
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(.white)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .multilineTextAlignment(.center)
        .offset(y: 20)
        .lineLimit(4)
        .onTapGesture {
          self.handleTap()
        }
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Secrets Unveiled"),
        message: Text(QuirkyMessageUtil.quirkyGoAwayMessage()),
        dismissButton: .default(Text("OK"))
      )
    }
  }

  private func handleTap() {
    tapCount += 1

    if tapCount >= 5 {
      showAlert = true
      tapCount = 0
    }
  }
}
