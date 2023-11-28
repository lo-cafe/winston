//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI



struct TabBarOverlay: View {
  var router: Router
  var tabHeight: CGFloat
  var meTabTap: () -> ()
  
  var body: some View {
    GeometryReader { geo in
      AccountSwitcherTrigger(onTap: meTabTap) {
        Color.clear
          .frame(maxWidth: UIScreen.screenWidth / 5, minHeight: tabHeight, maxHeight: tabHeight)
          .background(Color.clear)
          .contentShape(Rectangle())
      }
      .frame(width: geo.size.width, height: tabHeight)
      .contentShape(Rectangle())
      .swipeAnywhere(routerProxy: RouterProxy(router), routerContainer: router.isRootWrapper, forceEnable: true)
      .padding(.bottom, getSafeArea().bottom)
      .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
    }
    .ignoresSafeArea(.all)
  }
}

