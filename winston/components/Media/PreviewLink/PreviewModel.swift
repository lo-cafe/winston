//
//  PreviewModel.swift
//  winston
//
//  Created by Igor Marcossi on 26/09/23.
//

import Foundation
import SwiftUI
import OpenGraph
import NukeUI
import Defaults

@Observable
final class PreviewModel: Equatable {
  static func == (lhs: PreviewModel, rhs: PreviewModel) -> Bool {
    lhs.url == rhs.url
  }
  
  var imageReq: ImageRequest?
  var title: String?
  var url: URL?
  var description: String?
  var loading = true
  
  var previewURL: URL?
  
  init() {}
  
  init(_ url: URL, compact: Bool) {
    self.previewURL = url
    Task {
      await fetchMetadata(compact: compact)
    }
  }
  
  private func fetchMetadata(compact: Bool) async {
    guard let previewURL else { return }
    
      var headers = [String: String]()
      headers["User-Agent"] = "facebookexternalhit/1.1"
      headers["charset"] = "UTF-8"
      if let og = try? await OpenGraph.fetch(url: previewURL, headers: headers) {
        var newImageReq: ImageRequest?
        if let imgURL = URL(string: og[.image] ?? "") {
          newImageReq = ImageRequest(url: imgURL, processors: [.resize(width:  compact ? scaledCompactModeThumbSize() : 76)])
        }
        await MainActor.run { [newImageReq] in
          withAnimation {
            imageReq = newImageReq
            title = og[.title]?.escape
            description = og[.description]?.escape
            url = URL(string: og[.url] ?? "")
            loading = false
          }
        }
      } else {
        await MainActor.run {
          withAnimation {
            loading = false
          }
        }
    }
  }
}
