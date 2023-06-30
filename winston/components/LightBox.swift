//
//  LightBox.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CoreMedia
import VideoPlayer
import CachedAsyncImage

class ContentLightBox: Equatable, ObservableObject, Identifiable {
  static func ==(lhs: ContentLightBox, rhs: ContentLightBox) -> Bool {
    return lhs.url == rhs.url
  }
  @Published var url: String? = nil
  @Published var time: CMTime? = nil
  var id: String {
    url ?? UUID().uuidString
  }
}

struct LightBox: View {
  @EnvironmentObject var namespaceWrapper: NamespaceWrapper
  @EnvironmentObject var data: ContentLightBox
  @State var time = CMTime()
  @State var playingVideo = true
  @State var id: String?
  @State var appearBlack = false
  @State var drag: CGSize = .zero
  
  var body: some View {
    let interpolate = interpolatorBuilder([0, 100], value: max(abs(drag.width), abs(drag.height)))
    ZStack {
      if appearBlack {
        Color.black
          .opacity(interpolate([1, 0], false))
          .onTapGesture {
            withAnimation(.easeOut) {
              appearBlack = false
            }
            doThisAfter(0) {
              withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                data.url = nil
                data.time = nil
              }
            }
          }
          .allowsHitTesting(appearBlack)
          .transition(.opacity)
      }
      VStack {
        if let url = data.url {
          Group {
            if let _ = data.time {
              VideoPlayer(url:  URL(string: url)!, play: $playingVideo, time: $time)
                .contentMode(.scaleAspectFit)
                .matchedGeometryEffect(id: "\(url)-video", in: namespaceWrapper.namespace)
                .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-mask", in: namespaceWrapper.namespace))
              
              //                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
              CachedAsyncImage(url: URL(string: url)) { image in
                image
                //              Image("cat")
                  .resizable()
                  .scaledToFit()
                  .matchedGeometryEffect(id: "\(url)-img", in: namespaceWrapper.namespace)
              } placeholder: {
                EmptyView()
                  .zIndex(1)
              }
              .onTapGesture {
                withAnimation(.easeOut) {
                  appearBlack = data.url == nil
                }
                //                  doThisAfter(0) {
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                  data.url = data.url == nil ? id : nil
                }
                //                  }
              }
            }
          }
          .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-mask", in: namespaceWrapper.namespace))
          //          .scaleEffect(interpolate([1, 0.9], true))
          .offset(drag)
          .simultaneousGesture(
            DragGesture(minimumDistance: 0)
              .onChanged { val in
                var transaction = Transaction()
                transaction.isContinuous = true
                transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100)
                
                withTransaction(transaction) {
                  drag = val.translation
                }
              }
              .onEnded { val in
                let shouldClose = abs(val.translation.width) > 100 || abs(val.translation.height) > 100
                
                if shouldClose {
                  withAnimation(.easeOut) {
                    appearBlack = false
                  }
                }
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 20, initialVelocity: 0)) {
                  drag = .zero
                  if shouldClose {
                    data.url = nil
                    data.time = nil
                  }
                }
              }
          )
        }
      }
    }
    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    .onAppear {
      withAnimation(.easeOut) {
        appearBlack = true
      }
      id = data.url
    }
    .ignoresSafeArea(.all)
    .zIndex(999)
    .transition(.offset(x: 0, y: 1))
    .id("\(String(describing: data.url ?? id))-lightbox")
  }
}

//struct LightBox_Previews: PreviewProvider {
//    static var previews: some View {
//        LightBox()
//    }
//}
