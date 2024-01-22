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
  
  var image: String?
  var title: String?
  var url: URL?
  var description: String?
  var loading = true
  
  var previewURL: URL?
  
  init() {}
  
  init(_ url: URL, compact: Bool) {
    self.previewURL = url
    fetchMetadata(compact: compact)
  }
  
  static func get(_ url: URL, compact: Bool) -> PreviewModel {
    if let previewModel = Caches.postsPreviewModels.get(key: url.absoluteString) {
      return previewModel
    } else {
      let previewModel = PreviewModel(url, compact: compact)
      Caches.postsPreviewModels.addKeyValue(key: url.absoluteString, data: { previewModel })
      
      return previewModel
    }
  }
  
  private func fetchMetadata(compact: Bool) {
    guard let previewURL else { return }
    
    Task(priority: .background) {
      var headers = [String: String]()
      headers["User-Agent"] = "facebookexternalhit/1.1"
      headers["charset"] = "UTF-8"
      if let og = try? await OpenGraph.fetch(url: previewURL, headers: headers) {
        if let imgURL = URL(string: og[.image] ?? "") {
          Post.prefetcher.startPrefetching(with: [ImageRequest(url: imgURL, processors: [.resize(width:  compact ? scaledCompactModeThumbSize() : 76)], priority: .veryLow)])
        }
        await MainActor.run {
          withAnimation {
            image = og[.image]
            title = og[.title]
            description = og[.description]
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
}
