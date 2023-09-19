//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI
import SpriteKit

struct TabBarOverlay: View {
//  @Binding var activeTab: TabIdentifier
  var router: Router
  var tabHeight: CGFloat
  var meTabTap: () -> ()
  @State private var accountDrag: CGSize = .zero
  @State private var choosingAccount = false
  @State private var morph = MorphingGradientCircleScene()
  @State var medium = UIImpactFeedbackGenerator(style: .soft)
  
    var body: some View {
      GeometryReader { geo in
        Color.clear
          .frame(maxWidth: UIScreen.screenWidth / 5, minHeight: tabHeight, maxHeight: tabHeight)
          .overlay(
            !choosingAccount
            ? nil
            : ZStack {
              Circle()
                .fill( RadialGradient(
                  gradient: Gradient(stops: [
                    .init(color: Color.cyan, location: 0),
                    .init(color: Color.cyan.opacity(0.972), location: 0.044),
                    .init(color: Color.cyan.opacity(0.924), location: 0.083),
                    .init(color: Color.cyan.opacity(0.861), location: 0.121),
                    .init(color: Color.cyan.opacity(0.786), location: 0.159),
                    .init(color: Color.cyan.opacity(0.701), location: 0.197),
                    .init(color: Color.cyan.opacity(0.609), location: 0.238),
                    .init(color: Color.cyan.opacity(0.514), location: 0.284),
                    .init(color: Color.cyan.opacity(0.419), location: 0.335),
                    .init(color: Color.cyan.opacity(0.326), location: 0.395),
                    .init(color: Color.cyan.opacity(0.239), location: 0.463),
                    .init(color: Color.cyan.opacity(0.161), location: 0.542),
                    .init(color: Color.cyan.opacity(0.095), location: 0.634),
                    .init(color: Color.cyan.opacity(0.044), location: 0.74),
                    .init(color: Color.cyan.opacity(0.012), location: 0.861),
                    .init(color: Color.cyan.opacity(0), location: 1)
                  ]),
                  center: .center,
                  startRadius: 0,
                  endRadius: 300
                ))
                .opacity(0.5)
                .frame(width: 600, height: 600)
              VStack(spacing: 6) {
                Image("winstonNoBG")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 60, height: 60)
                Text("Account switcher\ncoming soon...")
                  .fontSize(15, .medium)
                  .opacity(1)
              }
              .offset(y: -100)
              SpriteView(scene: morph, transition: nil, isPaused: false, preferredFramesPerSecond: UIScreen.main.maximumFramesPerSecond, options: [.allowsTransparency, .ignoresSiblingOrder])
                .frame(width: 600, height: 600)
                .blur(radius: 32)
                .offset(accountDrag)
                .transition(.scale.combined(with: .opacity))
            }
              .multilineTextAlignment(.center)
              .allowsHitTesting(false)
          )
          .contentShape(Rectangle())
          .onTapGesture {
            meTabTap()

          }
          .gesture(
            LongPressGesture()
              .onEnded({ val in
                medium.prepare()
                medium.impactOccurred(intensity: 1)
                withAnimation(spring) {
                  choosingAccount = true
                }
              })
              .sequenced(before: DragGesture(minimumDistance: 0))
              .onChanged { sequence in
                switch sequence {
                case .first(_):
                  break
                case .second(_, let dragVal):
                  if let dragVal = dragVal {
                    accountDrag = dragVal.translation
                  }
                }
              }
              .onEnded({ sequence in
                switch sequence {
                case .first(_):
                  break
                case .second(_, _):
                  withAnimation(spring) {
                    choosingAccount = false
                    accountDrag = .zero
                  }
                }
              })
          )
          .frame(width: geo.size.width, height: tabHeight)
          .contentShape(Rectangle())
          .swipeAnywhere(routerContainer: SwipeAnywhereRouterContainer(router), forceEnable: true)
          .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
        .ignoresSafeArea(.keyboard)
    }
}
