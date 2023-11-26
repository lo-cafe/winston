//
//  AccountSwitcherView.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

struct AccountSwitcherView: View {
  var accountDrag: TransLocGesture
  
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  @State private var showAccounts = false
  let radiusX: CGFloat = 100
  let radiusY: CGFloat = 50
  
//  func calculateXOffset(count: Int, index: Int) -> CGFloat {
//      let angle = CGFloat.pi / CGFloat(count-1) * CGFloat(index)
//      let xOffset = radiusX * cos(angle) - radiusX
//      return xOffset
//  }
//
//  func calculateYOffset(count: Int, index: Int) -> CGFloat {
//      let angle = CGFloat.pi / CGFloat(count-1) * CGFloat(index)
//      let yOffset = radiusY * sin(angle)
//      return yOffset
//  }
  
  func calculateXOffset(count: Int, index: Int) -> CGFloat {
      let angle = CGFloat.pi / CGFloat(count-1) * CGFloat(count - 1 - index)
      let xOffset = radiusX * cos(angle) - radiusX
      return xOffset
  }

  func calculateYOffset(count: Int, index: Int) -> CGFloat {
      let angle = CGFloat.pi / CGFloat(count-1) * CGFloat(count - 1 - index)
      let yOffset = radiusY * sin(angle)
      return yOffset
  }
  
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack {
        ForEach(Array(credentialsManager.credentials.enumerated()), id: \.element) { index, cred in
          let verticalOffset = -100.0
          let extra = (AccountSwitcherTarget.fontSize * 1.2) + AccountSwitcherTarget.vStackSpacing
          let targetSize = AccountSwitcherTarget.size + AccountSwitcherTarget.floatOffsetVariationAmount
          let x = self.calculateXOffset(count: credentialsManager.credentials.count, index: index)
          let y = -self.calculateYOffset(count: credentialsManager.credentials.count, index: index)
          let xMin = ((UIScreen.screenWidth - targetSize) / 2) + x + radiusX
          let xMax = xMin + targetSize
          let yMin = UIScreen.screenHeight - getSafeArea().bottom + verticalOffset - extra - (targetSize / 2) + y
          let yMax = yMin + targetSize
          let xRange = xMin...xMax
          let yRange = yMin...yMax
          if showAccounts {
            AccountSwitcherTarget(hovered: xRange.contains(accountDrag.location.width) && yRange.contains(accountDrag.location.height), account: cred)
              .offset(x: radiusX, y: verticalOffset)
              .offset(
                x: x,
                y: y
              )
              .transition(.scaleAndBlur.animation(.bouncy.delay(0.1 * Double(index))))
          }
        }
      }
      AccountSwitcherFingerLight()
        .offset(accountDrag.translation)
    }
    .onAppear {
//      doThisAfter(0.1) {
        withAnimation(.bouncy) { showAccounts = true }
//      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .background(
      AccountSwitcherGradientBackground()
      , alignment: .bottom
    )
    .multilineTextAlignment(.center)
    .allowsHitTesting(false)
  }
}
