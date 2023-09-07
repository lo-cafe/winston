//
//  SimpleLightBoxOverlay.swift
//  winston
//
//  Created by Daniel Inama on 07/09/23.
//

import SwiftUI
import AlertToast

struct SimpleLightBoxOverlay: View {
  @State var done: Bool = false
  var opacity: CGFloat
  var url: URL
  @Environment(\.dismiss) var dismiss
  
  @State private var isPresentingShareSheet = false
  @State private var sharedImageData: Data?
  var body: some View {
    HStack{
      LightBoxButton(icon: "square.and.arrow.down") {
        saveMedia(url.absoluteString, .image) { result in
          done.toggle()
        }
      }.toast(isPresenting: $done, alert:{
        AlertToast(displayMode: .alert, type: .complete(Color.primary), title: "Image Saved")
      })
      //        ShareLink(item: imagesArr[activeIndex].url.absoluteString) {
      //          LightBoxButton(icon: "square.and.arrow.up") {}
      //            .allowsHitTesting(false)
      //            .contentShape(Circle())
      //        }
      LightBoxButton(icon: "square.and.arrow.up"){
        Task{
          sharedImageData = try await downloadAndSaveImage(url: url)
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
