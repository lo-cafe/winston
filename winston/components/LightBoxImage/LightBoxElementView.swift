//
//  LightBoxElementView.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI
import NukeUI

struct LightBoxElement: Identifiable, Equatable {
  var url: String
  var size: CGSize
  var id: String { self.url }
}

struct LightBoxElementView: View {
  var el: ImgExtracted
  var onTap: (()->())?
  var doLiveText: Bool
  @Binding var isPinching: Bool
  @State private var altSize: CGSize = .zero
  @Binding var isZoomed: Bool
  var body: some View {
<<<<<<< Updated upstream
    ZoomableScrollView(onTap: onTap, isZoomed: $isZoomed){
      URLImage(url: el.url, doLiveText: doLiveText)
      .scaledToFit()
=======
//        ZoomableScrollView(onTap: onTap, isZoomed: $isZoomed){
    Group {
      if let uiImg = el.uiImage {
        let id = el.url.absoluteString
        Image(uiImage: uiImg)
          .resizable()
          .matchedGeometryEffect(id: id, in: ns)
          .aspectRatio(contentMode: .fit)
          .frame(width: .screenW * scaleEffect)
          .mask(RoundedRectangle(cornerRadius: 0, style: .continuous).fill(.black).matchedGeometryEffect(id: "\(id)-mask", in: ns))
          .scaleEffect(1)
          .offset(offset)
//          .frame(.screenSize)
//          .background(.black)
          .transition(.scale(scale: 1))
      } else {
        URLImage(url: el.url, doLiveText: doLiveText)
          .aspectRatio(contentMode: .fit)
      }
>>>>>>> Stashed changes
    }
    .id("\(el.id)\(altSize.width + altSize.height)")
    .frame(width: .screenW)
    .preferredColorScheme(.dark)
    .edgesIgnoringSafeArea(.all)
    .statusBar(hidden: true)
  }
}
