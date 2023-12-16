//
//  AccountSwitcherGradientBackground.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SpriteKit
import SwiftUI
import UIKit

let startColor = UIColor(hex: "#E9CBFB")
let endColor = UIColor(hex: "#D9A4F9")

let startColorRGB = startColor.rgb
let endColorRGB = endColor.rgb

let opacities: [Double] = [1,1.000,1.000,0.861,0.786,0.701,0.609,0.514,0.419,0.326,0.239,0.161,0.095,0.044,0]
let locations: [Double] = [0,0.083,0.121,0.159,0.197,0.238,0.284,0.335,0.395,0.463,0.542,0.634,0.740,0.861,1]

func gradientColor(start: (CGFloat, CGFloat, CGFloat), end: (CGFloat, CGFloat, CGFloat), location: Double, opacity: Double) -> Gradient.Stop {
  
  let r = start.0 + CGFloat(location) * (end.0 - start.0)
  let g = start.1 + CGFloat(location) * (end.1 - start.1)
  let b = start.2 + CGFloat(location) * (end.2 - start.2)
  
  return Gradient.Stop(color: Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: CGFloat(opacity))), location: CGFloat(location))
}

extension UIColor {
  var rgb: (CGFloat, CGFloat, CGFloat) {
    var fRed: CGFloat = 0
    var fGreen: CGFloat = 0
    var fBlue: CGFloat = 0
    var fAlpha: CGFloat = 0
    
    if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
      return (fRed, fGreen, fBlue)
    } else {
      return (0, 0, 0)
    }
  }
}

func generateGradient() -> [Gradient.Stop] {
  var gradientStops: [Gradient.Stop] = []
  for i in 0..<locations.count {
    gradientStops.append(gradientColor(start: startColorRGB, end: endColorRGB, location: locations[i], opacity: opacities[i]))
  }
  return gradientStops
}

struct AccountSwitcherGradientBackgroundLayer: View, Equatable {
  static func == (lhs: AccountSwitcherGradientBackgroundLayer, rhs: AccountSwitcherGradientBackgroundLayer) -> Bool {
    true
  }
  
//  @State private var radius = 1.0
//  @State private var opacity = 1.0
//  private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

  var body: some View {
    Rectangle()
      .fill( EllipticalGradient(
        stops: generateGradient(),
        center: .bottom,
        startRadiusFraction: 0,
        endRadiusFraction: 1
      ))
//      .opacity(opacity)
      .offset(y: .screenH / 4)
//      .frame(maxWidth: .infinity, maxHeight: .infinity)
//      .onDisappear {
//        timer.d
//      }
//      .onReceive(timer) { _ in
//        withAnimation(.smooth) {
//          radius = Double.random(in: 0.5...1)
//          opacity = Double.random(in: 0.8...1)
//        }
//      }
  }
}

struct AccountSwitcherFlatennedBG: View, Equatable {
  static func == (lhs: AccountSwitcherFlatennedBG, rhs: AccountSwitcherFlatennedBG) -> Bool {
    true
  }
  
  var screenshot: UIImage
  private let date = Date()
  var body: some View {
//    ZStack {
//      TimelineView(.animation) { context in
//        let time = context.date.timeIntervalSince1970 - date.timeIntervalSince1970
        Image(uiImage: screenshot)
          .frame(.screenSize,  .bottom)
          .transition(.identity)
//          .modifier(ComplexWaveModifierVFX(time: time))
//      }
//    }
  }
}

struct AccountSwitcherGradientBackground: View, Equatable {
  static func == (lhs: AccountSwitcherGradientBackground, rhs: AccountSwitcherGradientBackground) -> Bool { true }
  
  @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
  @State private var opacities: [Double] = [1,1,1,1]
  
  var body: some View {
    ZStack(alignment: .bottom) {
//      AccountSwitcherGradientBackgroundLayer().equatable().opacity(0.15 * opacities[0]).drawingGroup()
      AccountSwitcherGradientBackgroundLayer().equatable().opacity(opacities[1]).drawingGroup().blendMode(.plusLighter)
//      ZStack(alignment: .bottom) {
//        AccountSwitcherGradientBackgroundLayer().equatable().opacity(opacities[2])
//        AccountSwitcherGradientBackgroundLayer().equatable().opacity(opacities[3])
//      }
//      .drawingGroup()
//      .blendMode(.overlay)
    }
    .ignoresSafeArea(.all)
    .frame(.screenSize,  .bottom)
    .onReceive(timer) { _ in
      withAnimation(.smooth) {
        let min: Double = 0.5
        opacities = [.random(in: min...1), .random(in: min...1), .random(in: min...1), .random(in: min...1)]
//        opacities = [.random(in: min...1), .random(in: min...1)]
      }
    }
  }
}

private struct ComplexWaveModifierVFX: ViewModifier {
  var time: CGFloat
  @State var go = false
  
  func body(content: Content) -> some View {
    content
//      .ifIOS17({ view in
//        if #available(iOS 17, *) {
//          view
//            .visualEffect { content, proxy in
//              content
//                .distortionEffect(ShaderLibrary[dynamicMember: "water"](
//                  .float2(proxy.size),
//                  .float(time),
//                  .float(1),
//                  .float(1),
//                  .float(3)
//              ), maxSampleOffset: .zero)
////                .distortionEffect(
////                  ShaderLibrary.complexWave(
////                    .float(time),
////                    .float(2.25),
////                    .float(1.5),
////                    .float(2.25),
////                    .float2(proxy.size)
////                  ),
////                  maxSampleOffset: .zero
////                )
//            }
//        }
//      })
  }
}
