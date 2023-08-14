//
//  LightBoxOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI

struct LightBoxOverlay: View {
  var post: Post
  var opacity: CGFloat
  var imagesArr: [LightBoxElement]
  var activeIndex: Int
  @Binding var loading: Bool
  @Binding var done: Bool
    var body: some View {
      VStack(alignment: .leading) {
        VStack(alignment: .leading, spacing: 8) {
          if let title = post.data?.title {
            Text(title)
              .fontSize(20, .semibold)
              .allowsHitTesting(false)
          }
          if let data = post.data, let fullname = data.author_fullname {
            Badge(author: data.author, fullname: fullname, created: data.created)
              .id("post-badge")
              .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 8, trailing: 8))
          }
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
              .frame(height: 150)
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
              .frame(height: 150)
          }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
        )
        .compositingGroup()
        .opacity(opacity)
        .allowsHitTesting(opacity != 0)
    }
}
