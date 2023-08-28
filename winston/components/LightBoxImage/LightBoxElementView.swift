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
  var body: some View {
    ZoomableScrollView(onTap: onTap){
      URLImage(url: el.url, doLiveText: doLiveText)
    }
    .frame(width: UIScreen.screenWidth) //TODO: .frame(maxWidth: .infinity, maxHeight: .infinity) Is the better approach than using the UIScreen
    .preferredColorScheme(.dark)
    .edgesIgnoringSafeArea(.all)
    .statusBar(hidden: true)

  }
}
