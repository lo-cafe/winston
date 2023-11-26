//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI

struct TransLocGesture: Equatable, Hashable {
  static let zero = TransLocGesture(translation: .zero, location: .zero)
  let translation: CGSize
  let location: CGSize
}

struct TabBarOverlay: View {
  //  @Binding var activeTab: TabIdentifier
  var router: Router
  var tabHeight: CGFloat
  var meTabTap: () -> ()
  @State private var accountDrag: TransLocGesture = .zero
  @State private var choosingAccount = false
  @State var medium = UIImpactFeedbackGenerator(style: .soft)
  
  var body: some View {
    GeometryReader { geo in
      Color.clear
        .frame(maxWidth: UIScreen.screenWidth / 5, minHeight: tabHeight, maxHeight: tabHeight)
//        .background(.red)
        .background(Color.clear)
        .contentShape(Rectangle())
        .simultaneousGesture(
          TapGesture()
            .onEnded { _ in
              meTabTap()
            }
        )
        .simultaneousGesture(
          LongPressGesture(minimumDuration: 0.15)
            .onEnded({ val in
              medium.prepare()
              medium.impactOccurred(intensity: 1)
              withAnimation(spring) {
                choosingAccount = true
              }
            })
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { sequence in
              switch sequence {
              case .first(_):
                break
              case .second(_, let dragVal):
                if let dragVal = dragVal {
                  accountDrag = .init(translation: dragVal.translation, location: .init(width: dragVal.location.x, height: dragVal.location.y) )
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
      //          .swipeAnywhere(routerProxy: RouterProxy(router), routerContainer: router.isRootWrapper, forceEnable: true)
        .padding(.bottom, getSafeArea().bottom)
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        .overlay(
          !choosingAccount
          ? nil
          : AccountSwitcherView(accountDrag: accountDrag)
          , alignment: .bottom
        )
    }
    .ignoresSafeArea(.all)
  }
}

