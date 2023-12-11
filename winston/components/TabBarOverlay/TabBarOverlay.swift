//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI



struct TabBarOverlay: View {
  var tabHeight: CGFloat?
  var meTabTap: () -> ()
  
  var body: some View {
    if let tabHeight = tabHeight {
      GeometryReader { geo in
        AccountSwitcherTrigger(onTap: meTabTap) {
          Color.clear
            .frame(width: UIScreen.screenWidth / 5, height: max(0, (tabHeight)))
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .frame(width: geo.size.width, height: max(0, (tabHeight)))
        .contentShape(Rectangle())
        .swipeAnywhere(forceEnable: true)
        .padding(.bottom, getSafeArea().bottom)
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
      .ignoresSafeArea(.all)
    }
  }
}

