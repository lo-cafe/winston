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
  var doLiveText: Bool = false
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
