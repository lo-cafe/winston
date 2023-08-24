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
  
  init(_ url: URL, compact: Bool = false) {
    let link = url.absoluteString
    self.url = url
    self.compact = compact
    if PreviewLinkCache.shared.cache[link].isNil {
      PreviewLinkCache.shared.cache[link] = PreviewViewModel(url)
    }
  }
  
  var body: some View {
    PreviewLinkContent(compact: compact, viewModel: PreviewLinkCache.shared.cache[url.absoluteString]!, url: url)
  }
}
