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

struct PreviewLinkContent: View {
  var compact: Bool
  @ObservedObject var viewModel: PreviewModel
  var url: URL
  static let height: CGFloat = 88
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var routerProxy: RouterProxy
  @ObservedObject private var tempGlobalState = TempGlobalState.shared
  @Default(.openLinksInSafari) private var openLinksInSafari
  var body: some View {
    PreviewLinkContentRaw(compact: compact, image: viewModel.image, title: viewModel.title, description: viewModel.description, loading: viewModel.loading, url: url, openURL: openURL, routerProxy: routerProxy, globalURL: $tempGlobalState.inAppBrowserURL, openLinksInSafari: openLinksInSafari)
  }
}


struct PreviewLinkContentRaw: View, Equatable {
  static func == (lhs: PreviewLinkContentRaw, rhs: PreviewLinkContentRaw) -> Bool {
    lhs.image == rhs.image && lhs.title == rhs.title && lhs.compact == rhs.compact && lhs.description == rhs.description && lhs.loading == rhs.loading && lhs.url == rhs.url && lhs.openLinksInSafari == rhs.openLinksInSafari
  }
  
  static let height: CGFloat = 88
  var compact: Bool
  var image: String?
  var title: String?
  var description: String?
  var loading: Bool
  var url: URL
  var openURL: OpenURLAction
  var routerProxy: RouterProxy
  @Binding var globalURL: URL?
  var openLinksInSafari: Bool
  
  var body: some View {
    HStack(spacing: 16) {
      
      if !compact {
        VStack(alignment: .leading, spacing: 2) {
          VStack(alignment: .leading, spacing: 0) {
            Text(title?.escape ?? "No title detected")
              .fontSize(17, .medium)
              .lineLimit(1)
              .truncationMode(.tail)
              .fixedSize(horizontal: false, vertical: true)
            
            Text(url.absoluteString)
              .fontSize(13)
              .opacity(0.5)
              .lineLimit(1)
              .fixedSize(horizontal: false, vertical: true)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          Text(description?.escape ?? "No description detected")
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
        if let image = image, let imageURL = URL(string: image) {
          URLImage(url: imageURL, processors: [.resize(width:  compact ? scaledCompactModeThumbSize() : 76)])
            .scaledToFill()
        } else {
          if loading {
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
        UIPasteboard.general.string = url.absoluteString
      } label: {
        Label("Copy URL", systemImage: "link")
      }
    }
    .highPriorityGesture(TapGesture().onEnded {
      if let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://reddit.com/", with: "winstonapp://")) {
        if openLinksInSafari {
          openURL(newURL)
        } else {
          globalURL = newURL
        }
      }
    })
  }
}
