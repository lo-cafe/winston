//
//  themeImportingListener.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import Foundation
import SwiftUI
import Defaults

struct ThemeImportingListenerModifier: ViewModifier {
  @State private var alert = false
  @Environment(\.globalLoaderStart) private var globalLoaderStart
  @Environment(\.globalLoaderDismiss) private var globalLoaderDismiss
  func body(content: Content) -> some View {
    content
      .alert("Success!", isPresented: $alert) {
        Button("Nice!", role: .cancel) {
          alert = false
        }
      } message: {
        Text("The theme was imported successfully. Enable it in \"Themes\" section in the Settings tab.")
      }
      .onOpenURL { url in
        if url.absoluteString.hasSuffix(".winston") || url.absoluteString.hasSuffix(".zip") {
          globalLoaderStart("Importing...")
          let result = importTheme(at: url)
          globalLoaderDismiss()
          if result {
            alert = true
          }
        }
      }
  }
}

extension View {
  func themeImportingListener() -> some View {
    self.modifier(ThemeImportingListenerModifier())
  }
}
