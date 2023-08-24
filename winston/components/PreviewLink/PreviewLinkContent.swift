//
//  PreviewLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import Foundation
import SwiftUI
import NukeUI
import OpenGraph
import SkeletonUI
import YouTubePlayerKit
import Defaults

class PreviewLinkCache {
  static var shared = PreviewLinkCache()
  var cache: [String:PreviewViewModel] = [:]
}

final class PreviewViewModel: ObservableObject {
  
  @Published var image: String?
  @Published var title: String?
  @Published var url: String?
  @Published var description: String?
  @Published var loading = true
  
  let previewURL: URL?
  
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
        await MainActor.run {
          withAnimation {
            image = og[.image]
            title = og[.title]
            description = og[.description]
            url = og[.url]
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



struct PreviewLinkContent: View {
  var compact: Bool
  @StateObject var viewModel: PreviewViewModel
  var url: URL
  private let height: CGFloat = 88
  @Environment(\.openURL) var openURL
  
  var body: some View {
    HStack(spacing: 16) {
      
      if !compact {
        VStack(alignment: .leading, spacing: 2) {
          VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.title?.escape ?? "No title detected")
              .fontSize(17, .medium)
              .lineLimit(1)
              .truncationMode(.tail)
              .fixedSize(horizontal: false, vertical: true)
            
            Text(viewModel.url == nil || viewModel.url?.isEmpty == true ? url.absoluteString : viewModel.url!)
              .fontSize(13)
              .opacity(0.5)
              .lineLimit(1)
              .fixedSize(horizontal: false, vertical: true)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          Text(viewModel.description?.escape ?? "No description detected")
            .fontSize(14)
            .lineLimit(2)
            .opacity(0.75)
            .fixedSize(horizontal: false, vertical: true)
        }
        .skeleton(with: viewModel.loading)
        .multiline(lines: 4, scales: [1: 1, 2: 0.5, 3: 0.75, 4: 0.75])
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
      }
      
      Group {
        if let image = viewModel.image, let imageURL = URL(string: image) {
          URLImage(url: imageURL)
            .scaledToFill()
        } else {
          if viewModel.loading {
            ProgressView()
          } else {
            Image(systemName: "link")
              .fontSize(20, .semibold)
          }
        }
      }
      .frame(width:  compact ? scaledCompactModeThumbSize() : 76, height:  compact ? scaledCompactModeThumbSize() : 76)
      .clipped()
      .mask(RR(12, .black))
      .background(RR(12, .primary.opacity(0.05)))
    }
    .padding(.vertical, compact ? 0 : 6)
    .padding(.leading, compact ? 0 : 10)
    .padding(.trailing, compact ? 0 : 6)
    .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? nil : height, maxHeight: compact ? nil : height)
    .background(compact ? nil : RR(16, .primary.opacity(0.05)))
    .contextMenu {
      Button {
        UIPasteboard.general.string = viewModel.url ?? url.absoluteString
      } label: {
        Label("Copy URL", systemImage: "link")
      }
    }
    .highPriorityGesture(TapGesture().onEnded {
      if let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://reddit.com/", with: "winstonapp://")) {
        openURL(newURL)
      }
    })
  }
}
