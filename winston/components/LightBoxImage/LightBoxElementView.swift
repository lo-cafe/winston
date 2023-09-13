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
  var el: MediaExtracted?
  var onTap: (()->())?
  var doLiveText: Bool = false
  var url: URL?
  @State private var altSize: CGSize = .zero
  @Binding var isZoomed: Bool
  var body: some View {
    ZoomableScrollView(onTap: onTap, isZoomed: $isZoomed){
      URLImage(url: el?.url ?? url!, doLiveText: doLiveText)
      .background(
        el?.size ?? .zero != .zero
        ? nil
        : GeometryReader { geo in
          Color.clear
            .onAppear { altSize = geo.size }
            .onChange(of: geo.size) {
              newValue in altSize = newValue
            }
        }
      )
    }
    .id("\(el?.id ?? UUID().uuidString)\(altSize.width + altSize.height)")
    .frame(width: UIScreen.screenWidth) //TODO: .frame(maxWidth: .infinity, maxHeight: .infinity) Is the better approach than using the UIScreen
    .preferredColorScheme(.dark)
    .edgesIgnoringSafeArea(.all)
    .statusBar(hidden: true)
  }
}
