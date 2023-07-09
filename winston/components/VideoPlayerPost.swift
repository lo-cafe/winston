//
//  VideoPlayerPost.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import Defaults
import VideoPlayer
import CoreMedia
import ASCollectionView

struct VideoPlayerPost: View {
  var prefix: String = ""
  var post: Post
  @State var playingVideo = true
  @State private var time: CMTime = .zero
  @EnvironmentObject var lightBoxType: ContentLightBox
  @EnvironmentObject var namespaceWrapper: NamespaceWrapper
  
  var body: some View {
    let media = post.data!.secure_media!
    switch media {
    case .first(let data):
      if let url = data.reddit_video?.fallback_url {
        if lightBoxType.post != post {
          VideoPlayer(url:  URL(string: url)!, play: $playingVideo, time: $time)
            .contentMode(.scaleAspectFill)
//            .matchedGeometryEffect(id: "\(url)-\(prefix)video", in: namespaceWrapper.namespace, isSource: true)
            .frame(height: 600)
//            .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-\(prefix)mask", in: namespaceWrapper.namespace))
            .mask(RR(12, .black))
            .id(url)
            .onTapGesture {
              withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) {
                lightBoxType.post = post
                lightBoxType.time = time
              }
            }
        } else {
          Color.clear
            .frame(maxWidth: .infinity, minHeight: 600)
            .zIndex(1)
        }
      } else {
        EmptyView()
      }
    case .second(_):
      EmptyView()
    }
  }
}
