//
//  blurTransitions.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import Foundation
import SwiftUI

struct BlurAndFadeEffect: ViewModifier {
  let isActive: Bool
  
  func body(content: Content) -> some View {
    content
      .opacity(isActive ? 1 : 0)
      .blur(radius: isActive ? 0 : 12)
  }
}

struct BlurAndSlide: ViewModifier {
  let isActive: Bool
  let top: Bool
  
  func body(content: Content) -> some View {
    content
    //                        .scaleEffect(isActive ? 1 : 0.001)
      .opacity(isActive ? 1 : 0)
      .offset(y: isActive ? 0 : top ? -128 : 128)
      .blur(radius: isActive ? 0 : 30)
      .zIndex(isActive ? 0 : -1)
  }
}

struct BlurAndSlideH: ViewModifier {
  let isActive: Bool
  let left: Bool
  
  func body(content: Content) -> some View {
    content
    //                        .scaleEffect(isActive ? 1 : 0.001)
      .opacity(isActive ? 1 : 0)
      .offset(x: isActive ? 0 : left ? -128 : 128)
      .blur(radius: isActive ? 0 : 30)
      .zIndex(isActive ? 0 : -1)
  }
}

struct ScaleAndBlurEffect: ViewModifier {
  let isActive: Bool
  
  func body(content: Content) -> some View {
    content
      .scaleEffect(isActive ? 1 : 0.75)
      .opacity(isActive ? 1 : 0)
      .blur(radius: isActive ? 0 : 30)
      .zIndex(isActive ? 0 : -1)
  }
}

extension AnyTransition {
  static var leaveToTop: AnyTransition {
    .modifier(
      active: BlurAndSlide(isActive: false, top: true),
      identity: BlurAndSlide(isActive: true, top: true)
    )
  }
  static var leaveToBottom: AnyTransition {
    .modifier(
      active: BlurAndSlide(isActive: false, top: false),
      identity: BlurAndSlide(isActive: true, top: false)
    )
  }
  static var leaveToLeft: AnyTransition {
    .modifier(
      active: BlurAndSlideH(isActive: false, left: true),
      identity: BlurAndSlideH(isActive: true, left: true)
    )
  }
  static var leaveToRight: AnyTransition {
    .modifier(
      active: BlurAndSlideH(isActive: false, left: false),
      identity: BlurAndSlideH(isActive: true, left: false)
    )
  }
  static var scaleAndBlur: AnyTransition {
    if #available(iOS 17, *) {
      return AnyTransition(.blurReplace)
    } else  {
      return .modifier(
        active: ScaleAndBlurEffect(isActive: false),
        identity: ScaleAndBlurEffect(isActive: true)
      )
    }
  }
  
  static var fadeBlur: AnyTransition {
    .modifier(
      active: BlurAndFadeEffect(isActive: false),
      identity: BlurAndFadeEffect(isActive: true)
    )
  }
}
