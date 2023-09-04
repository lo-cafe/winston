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
  @ObservedObject private var sharedCache = PreviewLinkCache.shared
  
  init(url: URL, compact: Bool = false) {
    self.url = url
    self.compact = compact
    sharedCache.addKeyValue(key: url.absoluteString, url: url)
  }
  
  var body: some View {
    PreviewLinkContent(compact: compact, viewModel: sharedCache[url.absoluteString]?.model ?? PreviewViewModel(url), url: url)
  }
}
