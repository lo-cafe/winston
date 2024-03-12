//
//  AccountSwitcherFingerLight.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

struct AccountSwitcherFingerLightLayer: View, Equatable {
  var body: some View {
    Circle().fill(Color.hex("F1D9FF"))
      .frame(width: 50, height: 50)
      .blur(radius: 32)
  }
}

struct AccountSwitcherFingerLight: View, Equatable {
  var body: some View {
    Image(.spotlight)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(200)
  }
}

