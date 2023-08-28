//
//  LightBoxElementView2.swift
//  winston
//
//  Created by Daniel Inama on 26/08/23.
//

import SwiftUI
import NukeUI
import Nuke
import NukeExtensions

struct LightBoxElementView: View {
  var el: MediaExtracted
  var onTap: (()->())?
  @Binding var isPinching: Bool
  var doLiveText: Bool = false
  @State private var anchor: UnitPoint = .zero
  @State private var offset: CGSize = .zero
  @State private var altSize: CGSize = .zero
  var body: some View {
    ZoomableScrollView(onTap: onTap){
      URLImage(url: el.url, doLiveText: doLiveText)
    }
    .frame(width: UIScreen.screenWidth) //TODO: .frame(maxWidth: .infinity, maxHeight: .infinity) Is the better approach than using the UIScreen
    .preferredColorScheme(.dark)
    .edgesIgnoringSafeArea(.all)
    .statusBar(hidden: true)

    URLImage(url: el.url, doLiveText: doLiveText)
    .scaledToFit()
    .background(
      el.size != .zero
      ? nil
      : GeometryReader { geo in
        Color.clear
          .onAppear { altSize = geo.size }
          .onChange(of: geo.size) { newValue in altSize = newValue }
      }
    )
    .pinchToZoom(onTap: onTap, size: el.size == .zero ? altSize : el.size, isPinching: $isPinching, scale: $scale, anchor: $anchor, offset: $offset)
    .id("\(el.id)\(altSize.width + altSize.height)")
  }
}
