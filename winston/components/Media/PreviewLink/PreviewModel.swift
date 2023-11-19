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

final class PreviewModel: ObservableObject, Equatable {
  static func == (lhs: PreviewModel, rhs: PreviewModel) -> Bool {
    lhs.url == rhs.url
  }
  
  @Published var image: String?
  @Published var title: String?
  @Published var url: URL?
  @Published var description: String?
  @Published var loading = true
  
  var previewURL: URL? {
    didSet {
      if previewURL != nil { fetchMetadata() }
    }
  }
  
  init() {}
  
  init(_ url: URL) {
    self.previewURL = url
    fetchMetadata()
  }
  
  private func fetchMetadata() {
    guard let previewURL else { return }
    Task(priority: .background) {
      var headers = [String: String]()
      headers["User-Agent"] = "facebookexternalhit/1.1"
      headers["charset"] = "UTF-8"
      if let og = try? await OpenGraph.fetch(url: previewURL, headers: headers) {
        if let imgURL = URL(string: og[.image] ?? "") {
          Post.prefetcher.startPrefetching(with: [ImageRequest(url: imgURL, processors: [.resize(width:  Defaults[.compactMode] ? scaledCompactModeThumbSize() : 76)], priority: .veryLow)])
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
