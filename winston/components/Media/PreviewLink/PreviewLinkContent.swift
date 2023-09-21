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
import Combine

class PreviewLinkCache: ObservableObject {
  struct CacheItem {
    let model: PreviewViewModel
    let date: Date
  }
  
  static var shared = PreviewLinkCache()
  @Published var cache: [String: CacheItem] = [:]
  let cacheLimit = 50
  
  func addKeyValue(key: String, url: URL) {
    if !cache[key].isNil { return }
    Task(priority: .background) {
      // Create a new CacheItem with the current date
      let item = CacheItem(model: PreviewViewModel(url), date: Date())
      let oldestKey = cache.count > cacheLimit ? cache.min { a, b in a.value.date < b.value.date }?.key : nil
      
      // Add the item to the cache
      await MainActor.run {
        withAnimation {
          cache[key] = item
          if let oldestKey = oldestKey { cache.removeValue(forKey: oldestKey) }
        }
      }
    }
  }
  
  private let _objectWillChange = PassthroughSubject<Void, Never>()
  
  var objectWillChange: AnyPublisher<Void, Never> { _objectWillChange.eraseToAnyPublisher() }
  
  subscript(key: String) -> CacheItem? {
    get { cache[key] }
    set {
      cache[key] = newValue
      _objectWillChange.send()
    }
  }
  
  func merge(_ dict: [String:CacheItem]) {
    cache.merge(dict) { (_, new) in new }
    _objectWillChange.send()
  }
}

//class PreviewLinkCache: ObservableObject {
//  static var shared = PreviewLinkCache()
//  @Published var cache: [String:PreviewViewModel] = [:]
//}

final class PreviewViewModel: ObservableObject {
  
  @Published var image: String?
  @Published var title: String?
  @Published var url: String?
  @Published var description: String?
  @Published var loading = true
  
  var previewURL: URL? {
    didSet {
      if !previewURL.isNil { fetchMetadata() }
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
  static let height: CGFloat = 88
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var routerProxy: RouterProxy
  @ObservedObject private var tempGlobalState = TempGlobalState.shared
  @Default(.openLinksInSafari) private var openLinksInSafari
  
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
//        .skeleton(with: viewModel.loading)
//        .multiline(lines: 4, scales: [1: 1, 2: 0.5, 3: 0.75, 4: 0.75])
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
      .mask(RR(12, Color.black))
      .background(RR(12, Color.primary.opacity(0.05)))
    }
    .padding(.vertical, compact ? 0 : 6)
    .padding(.leading, compact ? 0 : 10)
    .padding(.trailing, compact ? 0 : 6)
    .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? nil : PreviewLinkContent.height, maxHeight: compact ? nil : PreviewLinkContent.height)
    .background(compact ? nil : RR(16, Color.primary.opacity(0.05)))
    .contextMenu {
      Button {
        UIPasteboard.general.string = viewModel.url ?? url.absoluteString
      } label: {
        Label("Copy URL", systemImage: "link")
      }
    }
    .highPriorityGesture(TapGesture().onEnded {
      if let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://reddit.com/", with: "winstonapp://")) {
        if openLinksInSafari {
          openURL(newURL)
        } else {
          tempGlobalState.inAppBrowserURL = newURL
        }
      }
    })
  }
}
