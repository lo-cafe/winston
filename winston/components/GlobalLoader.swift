//
//  GlobalLoader.swift
//  winston
//
//  Created by Igor Marcossi on 08/08/23.
//

import SwiftUI

struct GlobalLoaderView: View {
  @ObservedObject var globalLoader = TempGlobalState.shared.globalLoader
    var body: some View {
      HStack(spacing: 8) {
        if globalLoader.loadingText == nil {
          Image(systemName: "checkmark.circle.fill")
            .transition(.scaleAndBlur)
            .foregroundColor(.green)
        } else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .teal))
            .transition(.scaleAndBlur)
        }

          Text(globalLoader.loadingText ?? "Done!")
          .foregroundColor(globalLoader.loadingText == nil ? .green : .teal)
          .fontSize(15, .semibold)
          .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
          .id(globalLoader.loadingText ?? "Done!")
          
      }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .floating()
        .mask(Capsule(style: .continuous).fill(.black))
        .frame(maxWidth: .infinity)
        .compositingGroup()
        .scaleEffect(1)
        .offset(y: !globalLoader.showing ? 75 : -62)
    }
}

class GlobalLoader: ObservableObject {
  @Published var loadingText: String?
  @Published var showing = false
  
  func enable(_ str: String) {
    self.loadingText = str
    doThisAfter(0) {
      withAnimation(spring) {
        self.showing = true
      }
    }
  }
  
  func dismiss() {
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    let soft = UIImpactFeedbackGenerator(style: .rigid)
    heavy.prepare()
    soft.prepare()
    withAnimation(.easeOut) {
      self.loadingText = nil
    }
    heavy.impactOccurred()
    doThisAfter(0.2) {
      soft.impactOccurred()
    }
    doThisAfter(0.75) {
      withAnimation(spring) {
        self.showing = false
      }
    }
  }
}
