//
//  LightBoxVideo.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CoreMedia
import AVKit
import Kingfisher

//struct LightBoxVideo: View {
//  @EnvironmentObject var data: ContentLightBox
//  @State var time = CMTime()
//  @State var playingVideo = true
//  @State var id: String?
//  @State var appearBlack = false
//  @State var drag: CGSize = .zero
//  @State var zoom: CGSize = .zero
//  @State var imgSize: CGSize = .zero
//  
//  var body: some View {
//    let interpolate = interpolatorBuilder([0, 100], value: max(abs(drag.width), abs(drag.height)))
//    ZStack {
//      if appearBlack {
//        Color.black
//          .opacity(interpolate([1, 0], false))
//          .onTapGesture {
//            withAnimation(.easeOut) {
//              appearBlack = false
//            }
//            doThisAfter(0) {
//              withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
//                data.post = nil
//                data.time = nil
//              }
//            }
//          }
//          .allowsHitTesting(appearBlack)
//          .transition(.opacity)
//      }
//      VStack {
//        if let postData = data.post?.data {
//          let url = postData.url
//            Text(postData.title)
//              .fontSize(20, .semibold)
//          Spacer()
//          Group {
//            if let _ = data.time {
//              VideoPlayer(url:  URL(string: url)!, play: $playingVideo, time: $time)
//                .contentMode(.scaleAspectFit)
////                .matchedGeometryEffect(id: "\(url)-video", in: namespaceWrapper.namespace)
//                .mask(RR(12, .black))
//              
//              //                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
//              KFImage(URL(string: url)!)
//                .resizable()
////                .matchedGeometryEffect(id: "\(url)-img", in: namespaceWrapper.namespace)
//                .scaledToFit()
////                .onTapGesture {
////                  withAnimation(.easeOut) {
////                    appearBlack = data.url == nil
////                  }
////                  //                  doThisAfter(0) {
////                  withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
////                    data.url = data.url == nil ? id : nil
////                  }
////                  //                  }
////                }
//            }
//          }
////          .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-mask", in: namespaceWrapper.namespace))
//          //          .scaleEffect(interpolate([1, 0.9], true))
//          .zIndex(1)
//          .offset(drag)
//          .simultaneousGesture(
//            DragGesture(minimumDistance: 0)
//              .onChanged { val in
//                var transaction = Transaction()
//                transaction.isContinuous = true
//                transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100)
//                
//                withTransaction(transaction) {
//                  drag = val.translation
//                }
//              }
//              .onEnded { val in
//                let shouldClose = abs(val.translation.width) > 100 || abs(val.translation.height) > 100
//                
//                if shouldClose {
//                  withAnimation(.easeOut) {
//                    appearBlack = false
//                  }
//                }
//                withAnimation(.interpolatingSpring(stiffness: 200, damping: 20, initialVelocity: 0)) {
//                  drag = .zero
//                  if shouldClose {
//                    data.post = nil
//                    data.time = nil
//                  }
//                }
//              }
//          )
//          
//          Spacer()
//          
//          
//          
//        }
//      }
//    }
//    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
//    .onAppear {
//      withAnimation(.easeOut) {
//        appearBlack = true
//      }
//      id = data.post!.id
//    }
//    .ignoresSafeArea(.all)
//    .zIndex(999)
//    .transition(.offset(x: 0, y: 1))
//    .id("\(String(describing: data.post?.id ?? id))-lightbox")
//  }
//}



struct LightBoxVideo: View {
  @Environment(\.dismiss) var dismiss
//  var size: CGSize
//  var videoURL: URL
  @ObservedObject var post: Post
  @ObservedObject var sharedVideo: SharedVideo
  var namespace: Namespace.ID
  @State var appearBlack = false
  @State var drag: CGSize = .zero
  @State var loading = false
  @State var done = false
  //  @State var zoom: CGSize = .zero
  //  @State var imgSize: CGSize = .zero
  
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
            //            doThisAfter(0) {
            //              withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            //                data.post = nil
            //                data.time = nil
            //              }
            //            }
          }
          .allowsHitTesting(appearBlack)
          .transition(.opacity)
      }
      VStack {
        if let title = post.data?.title, appearBlack {
          Text(title)
            .fontSize(20, .semibold)
            .opacity(interpolate([1, 0], false))
        }
        
        Spacer()
        
        VideoPlayer(player: sharedVideo.player)
          .introspect(.videoPlayer, on: .iOS(.v14, .v15, .v16, .v17)) { player in
            player.videoGravity = .resizeAspect
          }
          .matchedGeometryEffect(id: "\(post.id)-video", in: namespace)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
//          .contentMode(.scaleAspectFit)
        //                .matchedGeometryEffect(id: "\(url)-video", in: namespaceWrapper.namespace)
          .mask(RR(12, .black))
        //          .mask(RR(12, .black).matchedGeometryEffect(id: "\(imgURL.absoluteString)-mask", in: namespaceWrapper.namespace))
          .scaleEffect(interpolate([1, 0.9], true))
          .zIndex(1)
          .offset(drag)
          .blur(radius: loading ? 24 : 0)
//          .onTapGesture {
//            dismiss()
//          }
          .gesture(
            DragGesture(minimumDistance: 20)
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
                    dismiss()
                  }
                }
              }
          )
        
//        Spacer()
        
//        HStack(spacing: 12) {
//          LightBoxButton(icon: "square.and.arrow.down.fill") {
//            withAnimation(spring) {
//              loading = true
//            }
//            saveMedia(imgURL.absoluteString, .image) { result in
//              withAnimation(spring) {
//                done = true
//              }
//            }
//          }
//          ShareLink(item: imgURL) {
//            LightBoxButton(icon: "square.and.arrow.up.fill") {}
//            .allowsHitTesting(false)
//            .contentShape(Circle())
//          }
//        }
//        .compositingGroup()
//        .opacity(interpolate([1, 0], false))
//        .frame(maxWidth: .infinity)
      }
      .foregroundColor(.white)
      .padding(.bottom, 32)
      .padding(.top, 64)
      .overlay(
        !loading && !done
        ? nil
        : ZStack {
          if done {
            Image(systemName: "checkmark.circle.fill")
              .fontSize(40)
              .transition(.scaleAndBlur)
          } else {
            ProgressView()
              .transition(.scaleAndBlur)
          }
        }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.black.opacity(0.25))
      )
    }
    .onChange(of: done) { val in
      if val {
        doThisAfter(0.5) {
          withAnimation(spring) {
            done = false
            loading = false
          }
        }
      }
    }
    //    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea(edges: .all)
    .onAppear {
      withAnimation(.easeOut) {
        appearBlack = true
      }
    }
    //    .ignoresSafeArea(.all)
    //    .zIndex(999)
    .transition(.opacity)
    //    .transition(.offset(x: 0, y: 1))
  }
}
