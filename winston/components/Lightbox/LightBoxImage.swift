//
//  LightBox.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CoreMedia
import LonginusSwiftUI

struct LightBoxButton: View {
  @GestureState var pressed = false
  var icon: String
  var action: (()->())?
  var disabled = false
  var body: some View {
    Image(systemName: icon)
      .fontSize(20)
      .frame(width: 56, height: 56)
      .background(Circle().fill(.secondary.opacity(pressed ? 0.15 : 0)))
      .contentShape(Circle())
      .scaleEffect(pressed ? 0.95 : 1)
      .if(!disabled) {
        $0.onTapGesture {
          action?()
        }
        .simultaneousGesture(
          LongPressGesture(minimumDuration: 1)
            .updating($pressed, body: { newPressed, state, transaction in
              transaction.animation = .interpolatingSpring(stiffness: 250, damping: 15)
              state = newPressed
            })
        )
      }
      .transition(.scaleAndBlur)
      .id(icon)
  }
}

struct LightBoxElement: Identifiable, Equatable {
  var url: String
  var size: CGSize
  var id: String { self.url }
}

private let SPACING = 24.0

struct LightBoxImage: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var post: Post
  var i: Int
  var namespace: Namespace.ID
  @State var appearBlack = false
  @State var drag: CGSize = .zero
  @State var xPos: CGFloat = 0
  @State var dragAxis: Axis?
  @State var activeIndex = 0
  @State var loading = false
  @State var done = false
  @State var showOverlay = true
  @State var isPinching = false
  
  enum Axis {
    case horizontal
    case vertical
  }
  
  //  @State var zoom: CGSize = .zero
  //  @State var imgSize: CGSize = .zero
  
  var imagesArr: [LightBoxElement] {
    if post.data?.is_gallery == true {
      if let data = post.data?.media_metadata?.values {
        return data.compactMap { x in
          if let x = x, !x.id.isNil, let id = x.id, !id.isEmpty, let extArr = x.m?.split(separator: "/") {
            let ext = extArr[extArr.count - 1]
            return LightBoxElement(url: "https://i.redd.it/\(id).\(ext)", size: CGSize())
          }
          return nil
        }
      }
    } else {
      if let data = post.data, let preview = data.preview, preview.images?.count ?? 0 > 0, let source = preview.images?[0].source, let _ = source.url, let sourceHeight = source.height, let sourceWidth = source.width {
        return [LightBoxElement(url: data.url, size: CGSize(width: sourceWidth, height: sourceHeight))]
      }
      return []
    }
    return []
  }
  
  var body: some View {
    let interpolate = interpolatorBuilder([0, 100], value: abs(drag.height))
    //    let imagesArr = post.data?.is_gallery == true ?
      HStack(spacing: SPACING) {
        ForEach(Array(imagesArr.enumerated()), id: \.element.id) { i, img in
          let selected = i == activeIndex
//          let propHeight = (UIScreen.screenWidth * img.size.height) /  img.size.width
          LGImage(source: URL(string: img.url)!, placeholder: {
            ProgressView()
          }, options: [.imageWithFadeAnimation])
            .resizable()
//            .matchedGeometryEffect(id: img.url, in: namespace)
            .pinchToZoom(isPinching: $isPinching)
            .scaledToFit()
            .frame(width: UIScreen.screenWidth)
            .scaleEffect(!selected ? 1 : interpolate([1, 0.9], true))
            .blur(radius: selected && loading ? 24 : 0)
            .offset(x: !selected ? 0 : dragAxis == .vertical ? drag.width : 0, y: i != activeIndex ? 0 : dragAxis == .vertical ? drag.height : 0)
            .id(img.url)
        }
      }
      .fixedSize(horizontal: true, vertical: false)
      .offset(x: xPos + (dragAxis == .horizontal ? drag.width : 0))
      .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity, alignment: .leading)
      .clipped()
      .onTapGesture {
        withAnimation {
          showOverlay.toggle()
        }
      }
      .simultaneousGesture(
        DragGesture(minimumDistance: 20)
          .onChanged { val in
            if dragAxis == nil {
              if abs(val.predictedEndTranslation.width) > abs(val.predictedEndTranslation.height) {
                dragAxis = .horizontal
              } else if abs(val.predictedEndTranslation.width) < abs(val.predictedEndTranslation.height) {
                dragAxis = .vertical
              }
            }
            
            if dragAxis != nil {
              var transaction = Transaction()
              transaction.isContinuous = true
              transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
              
              var endPos = val.translation
              if dragAxis == .horizontal {
                endPos.height = 0
              }
              withTransaction(transaction) {
                drag = endPos
              }
            }
          }
          .onEnded { val in
            if dragAxis == .horizontal {
              let predictedEnd = val.predictedEndTranslation.width
              drag = .zero
              xPos += val.translation.width
              let newActiveIndex = min(imagesArr.count - 1, max(0, activeIndex + (predictedEnd < -(UIScreen.screenWidth / 2) ? 1 : predictedEnd > UIScreen.screenWidth / 2 ? -1 : 0)))
              let finalXPos = -(CGFloat(newActiveIndex) * (UIScreen.screenWidth + (SPACING)))
              let distance = abs(finalXPos - xPos)
              activeIndex = newActiveIndex
              var initialVel = abs(predictedEnd / distance)
              initialVel = initialVel < 3.75 ? 0 : initialVel * 2
              withAnimation(.interpolatingSpring(stiffness: 150, damping: 17, initialVelocity: initialVel)) {
                xPos = finalXPos
                dragAxis = nil
              }
            } else {
              let shouldClose = abs(val.translation.width) > 100 || abs(val.translation.height) > 100
              
              if shouldClose {
                withAnimation(.easeOut) {
                  appearBlack = false
                }
              }
              withAnimation(.interpolatingSpring(stiffness: 200, damping: 20, initialVelocity: 0)) {
                drag = .zero
                dragAxis = nil
                if shouldClose {
                  dismiss()
                }
              }
            }
          }
      )
    .overlay(
      VStack(alignment: .leading) {
        if let title = post.data?.title, appearBlack {
          Text(title)
            .fontSize(20, .semibold)
            .allowsHitTesting(false)
        }
        
        Spacer()
        
        if imagesArr.count > 1 {
          Text("\(activeIndex + 1)/\(imagesArr.count)")
            .fontSize(16, .semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule(style: .continuous).fill(.regularMaterial))
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)
        }
        
        HStack(spacing: 12) {
          LightBoxButton(icon: "square.and.arrow.down.fill") {
            withAnimation(spring) {
              loading = true
            }
            saveMedia(imagesArr[activeIndex].url, .image) { result in
              withAnimation(spring) {
                done = true
              }
            }
          }
          ShareLink(item: imagesArr[activeIndex].url) {
            LightBoxButton(icon: "square.and.arrow.up.fill") {}
              .allowsHitTesting(false)
              .contentShape(Circle())
          }
        }
        .compositingGroup()
        .frame(maxWidth: .infinity)
      }
        .multilineTextAlignment(.leading)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.bottom, 32)
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
          VStack(spacing: 0) {
            Rectangle()
              .fill(LinearGradient(
                gradient: Gradient(stops: [
                  .init(color: Color.black.opacity(1), location: 0),
                  .init(color: Color.black.opacity(0), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
              ))
              .frame(minHeight: 150)
            Spacer()
            Rectangle()
              .fill(LinearGradient(
                gradient: Gradient(stops: [
                  .init(color: Color.black.opacity(1), location: 0),
                  .init(color: Color.black.opacity(0), location: 1)
                ]),
                startPoint: .bottom,
                endPoint: .top
              ))
              .frame(minHeight: 150)
          }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
        )
        .compositingGroup()
        .opacity(!showOverlay ? 0 : isPinching ? 0 : interpolate([1, 0], false))
        .animation(.default, value: isPinching)
        .allowsHitTesting(showOverlay)
    )
    .background(
      !appearBlack
      ? nil
      : Color.black
          .opacity(interpolate([1, 0], false))
          .onTapGesture {
            withAnimation(.easeOut) {
              appearBlack = false
            }
          }
          .allowsHitTesting(appearBlack)
          .transition(.opacity)
    )
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea(edges: .all)
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
    .onAppear {
      xPos = -CGFloat(i) * (UIScreen.screenWidth + SPACING)
      activeIndex = i
      withAnimation(.easeOut) {
        appearBlack = true
      }
    }
    .transition(.opacity)
  }
}


