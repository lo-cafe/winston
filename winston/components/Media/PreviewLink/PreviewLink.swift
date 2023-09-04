//
//  File.swift
//  winston
//
//  Created by Igor Marcossi on 28/07/23.
//

import Foundation
import SwiftUI
import YouTubePlayerKit


struct PreviewLink: View {
  var url: URL
  var compact = false
  @StateObject var sharedCache = PreviewLinkCache.shared
  
  var body: some View {
    PreviewLinkContent(compact: compact, viewModel: sharedCache.cache[url.absoluteString]?.model ?? PreviewViewModel(url), url: url)
      .onAppear {
        sharedCache.addKeyValue(key: url.absoluteString, url: url)
      }
  }
}
