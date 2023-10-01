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
  @ObservedObject private var cache = Caches.postsPreviewModels
  
  var body: some View {
    PreviewLinkContent(compact: compact, viewModel: cache.cache[url.absoluteString]?.data ?? PreviewModel(url), url: url)
  }
}
