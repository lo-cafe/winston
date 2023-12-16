//
//  TabBarOverlay.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI



struct TabBarOverlay: View {
  var meTabTap: () -> ()
  
  @State private var bottomSafeArea = getSafeArea().bottom
  
  @Environment(\.tabBarHeight) private var tabBarHeight
  var body: some View {
    if let tabBarHeight {
      GeometryReader { geo in
        AccountSwitcherTrigger(onTap: meTabTap) {
          Color.clear
            .frame(width: .screenW / 5, height: max(0, (tabBarHeight)))
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .frame(width: geo.size.width, height: max(0, (tabBarHeight)))
        .contentShape(Rectangle())
        .swipeAnywhere(forceEnable: true)
        .padding(.bottom, bottomSafeArea)
        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
      .ignoresSafeArea(.all)
    }
  }
}

