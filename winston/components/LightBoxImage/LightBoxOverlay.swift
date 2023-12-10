//
//  LightBoxOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI
import Defaults
import NukeUI

struct LightBoxOverlay: View {
  let postTitle: String
  let badgeKit: BadgeKit
  let avatarImageRequest: ImageRequest?
  var opacity: CGFloat
  var imagesArr: [ImgExtracted]
  var activeIndex: Int
  @Binding var loading: Bool
  @Environment(\.dismiss) var dismiss
  @Binding var done: Bool
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs: ColorScheme
    @State private var isPresentingShareSheet = false
  @State private var sharedImageData: Data?
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 8) {
        Text(postTitle)
          .fontSize(20, .semibold)
          .allowsHitTesting(false)
        BadgeView(avatarRequest: avatarImageRequest, saved: false, usernameColor: nil, author: badgeKit.author, fullname: badgeKit.authorFullname, userFlair: badgeKit.userFlair, created: badgeKit.created, avatarURL: nil, theme: selectedTheme.postLinks.theme.badge, cs: cs)
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
        
          // MANDRAKE
//           if let post {
//               LightBoxButton(icon: "bubble.right") {
//             if let data = post.data {
//                   Nav.to(.reddit(.post(Post(id: post.id, sub: Subreddit(id: data.subreddit)))))
//                   dismiss()
//                 }
//               }
//           }
        
        
        LightBoxButton(icon: "square.and.arrow.down") {
          withAnimation(spring) {
            loading = true
          }
          saveMedia(imagesArr[activeIndex].url.absoluteString, .image) { result in
            withAnimation(spring) {
              done = true
            }
          }
        }
        LightBoxButton(icon: "square.and.arrow.up"){
          Task{
            sharedImageData = try await downloadAndSaveImage(url: imagesArr[activeIndex].url)
          }
          isPresentingShareSheet.toggle()
        }
        .contentShape(Circle())
        .sheet(isPresented: $isPresentingShareSheet) {
          if let sharedImageData = sharedImageData, let uiimg = UIImage(data: sharedImageData){
            let image = ShareImage(placeholderItem: uiimg)
            ShareSheet(items: [image])
          }
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
