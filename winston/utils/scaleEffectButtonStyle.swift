//
//  scaleEffectButtonStyle.swift
//  winston
//
//  Created by Daniel Inama on 11/08/23.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
  var scaleDepressed: CGFloat = 1
  var scalePressed: CGFloat = 1.4
  var anchor: UnitPoint = UnitPoint.center
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.scaleEffect(configuration.isPressed ? scalePressed : scaleDepressed)
  }
}
