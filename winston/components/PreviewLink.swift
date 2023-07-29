//
//  File.swift
//  winston
//
//  Created by Igor Marcossi on 28/07/23.
//

import Foundation
import SwiftUI
import Kingfisher
import OpenGraph
import SkeletonUI

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
  
  init(_ url: String) {
    self.previewURL = URL(string: url)
    
    fetchMetadata()
  }
  
  private func fetchMetadata() {
    guard let previewURL else { return }
    Task {
      if let og = try? await OpenGraph.fetch(url: previewURL) {
        
        
        await MainActor.run {
          withAnimation {
            image = og[.image]
            title = og[.title]
            description = og[.description]
            url = og[.url]
            loading = false
          }
        }
      }
    }
  }
}

struct PreviewLink: View {
  var url: String
  
  init(_ url: String) {
    self.url = url
    if PreviewLinkCache.shared.cache[url] == nil {
      PreviewLinkCache.shared.cache[url] = PreviewViewModel(url)
    }
  }
  
  var body: some View {
    PreviewLinkContent(viewModel: PreviewLinkCache.shared.cache[url]!, url: URL(string: url)!)
  }
}

struct PreviewLinkContent: View {
  @StateObject var viewModel: PreviewViewModel
  var url: URL
  private let height: CGFloat = 88
  @Environment(\.openURL) var openURL
  
  var body: some View {
    HStack(spacing: 16) {
      
      VStack(alignment: .leading, spacing: 2) {
        VStack(alignment: .leading, spacing: 0) {
          Text(viewModel.title ?? "")
            .fontSize(17, .medium)
          
          Text(viewModel.url ?? "")
            .fontSize(13)
            .opacity(0.5)
        }
        
        Text(viewModel.description)
          .fontSize(14)
          .lineLimit(2)
          .opacity(0.75)
          .fixedSize(horizontal: false, vertical: true)
      }
      .skeleton(with: viewModel.title.isNil)
      .multiline(lines: 4, scales: [1: 1, 2: 0.5, 3: 0.75, 4: 0.75])
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.leading)
      
      if let image = viewModel.image {
        KFImage(URL(string: image)!)
          .resizable()
          .fade(duration: 0.5)
          .backgroundDecode()
          .scaledToFill()
          .frame(width: 76, height: 76)
          .clipped()
          .mask(RR(12, .black))
      } else {
        ProgressView()
          .frame(width: 76, height: 76)
          .background(RR(12, .primary.opacity(0.05)))
      }
    }
    .padding(.vertical, 6)
    .padding(.leading, 10)
    .padding(.trailing, 6)
    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    .background(RR(16, .primary.opacity(0.05)))
    .onTapGesture {
      openURL(url)
    }
  }
}
