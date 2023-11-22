//
//  ListBigBtn.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import SwiftUI
import Shiny

struct ListBigBtn: View {
  @EnvironmentObject private var routerProxy: RouterProxy
  @Binding var selectedSub: FirstSelectable?
  var icon: String
  var iconColor: Color
  var label: String
  var destination: Subreddit
  @Environment(\.useTheme) private var theme
  var body: some View {
    Button {
      selectedSub = .sub(destination) 
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .fontSize(32)
          .foregroundColor(iconColor)
        Text(label)
          .fontSize(17, .semibold)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundColor(.primary)
      .themedListRowBG()
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(WNavLinkButtonStyle())
    .mask(RR(10, .black))
  }
}

struct ListBigNavLink: View {
  @EnvironmentObject private var routerProxy: RouterProxy
  var icon: String
  var iconColor: Color
  var label: String
  var value: any Hashable
  @Environment(\.useTheme) private var theme
  
  init(value: any Hashable, iconColor: Color, label: String, icon: String) {
    self.value = value
    self.label = label
    self.iconColor = iconColor
    self.icon = icon
    
  }
  
  
  var body: some View {
    Button {
      routerProxy.router.path.append(value)
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .fontSize(32)
          .foregroundColor(iconColor)
        Text(label)
          .fontSize(17, .semibold)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: 100)
      .foregroundColor(.primary)
//      .themedListRowBG()
      .shiny(.hyperGlossy(UIColor.systemGray5))
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(WNavLinkButtonStyle())
    .mask(RR(10, .black))
  }
}
