//
//  PreviewLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import Foundation
import SwiftUI
import UIKit
import NukeUI
import OpenGraph
import SkeletonUI
import YouTubePlayerKit
import Defaults
import Combine
import SafariServices

struct PreviewLinkContent: View {
  var compact: Bool
  @ObservedObject var viewModel: PreviewModel
  var url: URL
  static let height: CGFloat = 88
  @Environment(\.openURL) private var openURL
  @Default(.BehaviorDefSettings) private var behaviorDefSettings
  var body: some View {
    PreviewLinkContentRaw(compact: compact, image: viewModel.image, title: viewModel.title, description: viewModel.description, loading: viewModel.loading, url: url, openURL: openURL, openLinksInSafari: behaviorDefSettings.openLinksInSafari)
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
            
            Text(cleanURL(url: url))
              .fontSize(13)
              .opacity(0.5)
              .lineLimit(1)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          Text(description?.escape ?? "No description detected")
            .fontSize(14)
            .lineLimit(2)
            .opacity(0.75)
        }
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
      .background(RR(12, Color.primary.opacity(0.1)))
    }
    .padding(.vertical, compact ? 0 : 6)
    .padding(.leading, compact ? 0 : 10)
    .padding(.trailing, compact ? 0 : 6)
    .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? nil : PreviewLinkContent.height, maxHeight: compact ? nil : PreviewLinkContent.height)
    .background(compact ? nil : RR(16, Color.primary.opacity(0.1)))
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
          Nav.openURL(newURL)
        }
      }
    })
  }
}
