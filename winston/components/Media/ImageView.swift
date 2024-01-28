//
//  ImageView.swift
//  winston
//
//  Created by daniel (i think) on 1/10/24.
//

import SwiftUI
import NukeUI

struct ImageView: View {
  var url: URL
  @Namespace var presentationNamespace
  
  var body: some View {
    LightBoxImage(i: 0, imagesArr: [ImgExtracted(url: url, size: CGSize(width: 100, height: 100), request: ImageRequest(url: url))], doLiveText: true)
  }
}
