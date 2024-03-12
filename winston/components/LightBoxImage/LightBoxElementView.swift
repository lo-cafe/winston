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
    ZoomableScrollView(onTap: onTap, isZoomed: $isZoomed){
      URLImage(url: el.url, doLiveText: doLiveText)
      .scaledToFit()
    }
    .id("\(el.id)\(altSize.width + altSize.height)")
    .frame(width: .screenW)
    .preferredColorScheme(.dark)
    .edgesIgnoringSafeArea(.all)
    .statusBar(hidden: true)
  }
}
