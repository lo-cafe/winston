//
//  fontSize.swift
//  winston
//
//  Created by Igor Marcossi on 26/05/23.
//

import Foundation
import SwiftUI

//let MonoWeights: [NSFont.Weight:String] = [
//    .black: "JetBrainsMono-ExtraBold",
//    .bold: "JetBrainsMono-Bold",
//    .heavy: "JetBrainsMono-SemiBold",
//    .light: "JetBrainsMono-SemiBold",
//    .medium: "JetBrainsMono-Medium",
//    .regular: "JetBrainsMono-SemiBold",
//    .semibold: "JetBrainsMono-SemiBold",
//    .thin: "JetBrainsMono-SemiBold",
//    .ultraLight: "JetBrainsMono-SemiBold",
//]

extension View {
  func fontSize(_ size: CGFloat, _ weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
    self.font(.system(size: size, weight: weight, design: design))
    }
}
