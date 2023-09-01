//
//  LightBoxOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI
import Nuke


struct LightBoxOverlay: View {
  var post: Post
  var opacity: CGFloat
  var imagesArr: [MediaExtracted]
  var activeIndex: Int
  @Binding var loading: Bool
  @Binding var done: Bool
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) var dismiss
  
  @State private var isPresentingShareSheet = false
  @State private var sharedImageData: Data?
  
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
        
        //        if let data = post.data {
        //          VotesCluster(data:data, post: post)
        //            .foregroundStyle(.ultraThinMaterial)
        //            .padding()
        //            .background{
        //              Rectangle()
        //                .clipShape(RoundedRectangle(cornerRadius: 20))
        //            }
        //        }
        //
        LightBoxButton(icon: "bubble.right") {
          if let data = post.data {
            router.path.append(PostViewPayload(post: Post(id: post.id, api: post.redditAPI), sub: Subreddit(id: data.subreddit, api: post.redditAPI)))
            dismiss()
          }
        }
        
        LightBoxButton(icon: "icloud.and.arrow.down") {
          withAnimation(spring) {
            loading = true
          }
          saveMedia(imagesArr[activeIndex].url.absoluteString, .image) { result in
            withAnimation(spring) {
              done = true
            }
          }
        }
        //        ShareLink(item: imagesArr[activeIndex].url.absoluteString) {
        //          LightBoxButton(icon: "square.and.arrow.up") {}
        //            .allowsHitTesting(false)
        //            .contentShape(Circle())
        //        }
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
              .onAppear{
                print("Share sheet")
                print(image)
              }
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


