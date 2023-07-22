//
//  LightBox.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CoreMedia
import VideoPlayer
import Kingfisher

struct LightBoxButton: View {
  @GestureState var pressed = false
  var icon: String
  var action: ()->()
  var body: some View {
    Image(systemName: icon)
      .fontSize(20)
      .frame(width: 56, height: 56)
      .background(Circle().fill(.secondary.opacity(pressed ? 0.15 : 0)))
      .contentShape(Circle())
      .scaleEffect(pressed ? 0.95 : 1)
      .onTapGesture {
        action()
      }
      .simultaneousGesture(
      LongPressGesture(minimumDuration: 1)
        .updating($pressed, body: { newPressed, state, transaction in
          transaction.animation = .interpolatingSpring(stiffness: 250, damping: 15)
          state = newPressed
        })
      )
  }
}

struct LightBoxImage: View {
  @Environment(\.dismiss) var dismiss
  //  @Binding var switchImages: Bool
  @State var imgURL: URL
  //  var uiImage: UIImage?
  @State var post: Post
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
        
        KFImage(imgURL)
          .resizable()
          .fade(duration: 0.5)
          .matchedGeometryEffect(id: "\(imgURL.absoluteString)-img", in: namespace)
          .scaledToFit()
        //          .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-mask", in: namespaceWrapper.namespace))
          .scaleEffect(interpolate([1, 0.9], true))
          .zIndex(1)
          .offset(drag)
          .blur(radius: loading ? 24 : 0)
          .onTapGesture {
            dismiss()
          }
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
                    dismiss()
                    //                    data.post = nil
                    //                    data.time = nil
                  }
                }
              }
          )
        
        Spacer()
        
        HStack(spacing: 12) {
          LightBoxButton(icon: "square.and.arrow.down.fill") {
            withAnimation(spring) {
              loading = true
            }
            saveMedia(imgURL.absoluteString, .image) { result in
              withAnimation(spring) {
                done = true
              }
            }
          }
          LightBoxButton(icon: "square.and.arrow.up.fill") {
            shareMedia(imgURL.absoluteString, .image)
          }
        }
        .frame(maxWidth: .infinity)
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


