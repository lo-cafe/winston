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
  @State var previewModel: PreviewModel
  
  var body: some View {
    PreviewLinkContent(compact: compact, viewModel: previewModel, url: url)
  }
}
