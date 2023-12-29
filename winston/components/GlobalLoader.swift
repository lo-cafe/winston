//
//  GlobalLoader.swift
//  winston
//
//  Created by Igor Marcossi on 08/08/23.
//

import Foundation
import SwiftUI

struct GlobalLoaderView: View {
  var loader: GlobalLoader?
  var body: some View {
    HStack(spacing: 8) {
      if loader?.loadingText == nil {
        Image(systemName: "checkmark.circle.fill")
          .transition(.scaleAndBlur)
          .foregroundColor(.green)
      } else {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .teal))
          .transition(.scaleAndBlur)
      }
      
      Text(loader?.loadingText ?? "Done!")
        .foregroundColor(loader?.loadingText == nil ? .green : .teal)
        .fontSize(15, .semibold)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
        .id(loader?.loadingText ?? "Done!")
      
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .floating()
    .mask(Capsule(style: .continuous).fill(.black))
    .frame(maxWidth: .infinity)
    .compositingGroup()
    .scaleEffect(1)
    .offset(y: !(loader?.showing ?? false) ? 75 : -62)
  }
}

struct GlobalLoader {
  var loadingText: String?
  var showing = false
}

struct GlobalLoaderProviderModifier: ViewModifier {
  @State private var loader: GlobalLoader? = nil
  
  func enable(_ str: String) {
    self.loader = GlobalLoader(loadingText: str, showing: true)
    //    doThisAfter(0.0) {
    //      withAnimation(spring) {
    //        self.showing = true
    //      }
    //    }
  }
  
  func dismiss() {
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    let soft = UIImpactFeedbackGenerator(style: .rigid)
    heavy.prepare()
    soft.prepare()
    withAnimation(.easeOut) {
      self.loader?.loadingText = nil
    }
    heavy.impactOccurred()
    doThisAfter(0.2) {
      soft.impactOccurred()
    }
    doThisAfter(0.75) {
      withAnimation(spring) {
        self.loader?.showing = false
      }
    }
  }
  func body(content: Content) -> some View {
    content
      .environment(\.globalLoaderStart, enable)
      .environment(\.globalLoaderDismiss, dismiss)
      .overlay(
        GeometryReader { geo in
          GlobalLoaderView(loader: loader)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
          .ignoresSafeArea(.keyboard)
        , alignment: .bottom
      )
  }
}

extension View {
  func globalLoaderProvider() -> some View {
    self
      .modifier(ThemeImportingListenerModifier())
  }
}

private struct GlobalLoaderDismissLoadingKey: EnvironmentKey {
  static let defaultValue = {}
}

private struct GlobalLoaderStartLoadingKey: EnvironmentKey {
  static let defaultValue: (String) -> () = { _ in }
}

extension EnvironmentValues {
  var globalLoaderStart: (String) -> () {
    get { self[GlobalLoaderStartLoadingKey.self] }
    set { self[GlobalLoaderStartLoadingKey.self] = newValue }
  }
  var globalLoaderDismiss: () -> () {
    get { self[GlobalLoaderDismissLoadingKey.self] }
    set { self[GlobalLoaderDismissLoadingKey.self] = newValue }
  }
}
