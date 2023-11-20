//
//  WNavigationLink.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI

struct WListButton<Content: View>: View {
  var showArrow: Bool = false
  var active: Bool = false
  var action: () -> ()
  @ViewBuilder var label: (() -> Content)
  @EnvironmentObject private var routerProxy: RouterProxy
  
  init(showArrow: Bool = false, active: Bool = false, _ action: @escaping () -> (), @ViewBuilder label: @escaping () -> Content) {
    self.active = active
    self.action = action
    self.label = label
    self.showArrow = showArrow
  }
  
  var body: some View {
    Button {
      action()
    } label: {
      HStack {
        label()
        
        Spacer()
        
        if showArrow {
          Image(systemName: "chevron.right")
            .fontSize(14, .semibold)
            .opacity(0.35)
            .foregroundColor(.primary)
        }
      }
      .themedListRowBG(enablePadding: true, active: active)
      .contentShape(Rectangle())
    }
    .buttonStyle(WNavLinkButtonStyle(active: active))
    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
  }
}

struct WSListButton: View {
  var showArrow: Bool = false
  var active: Bool = false
  var action: () -> ()
  var label: String
  var icon: String? = nil
  @EnvironmentObject private var routerProxy: RouterProxy
  
  init(showArrow: Bool = false, _ label: String, active: Bool = false, icon: String? = nil, _ action: @escaping () -> ()) {
    self.active = active
    self.action = action
    self.label = label
    self.icon = icon
    self.showArrow = showArrow
  }
  
  var body: some View {
    WListButton(showArrow: showArrow, active: active) {
      action()
    } label: {
      if let icon = icon {
//        HStack {
//          Image(systemName: icon)
//            .foregroundStyle(Color.blue)
//          Text(label)
//        }
        Label(label, systemImage: icon)
      } else {
        Text(label)
      }
    }
    
  }
}

struct WNavigationLink<Content: View>: View {
  var value: any Hashable
  var active: Bool = false
  var label: (() -> Content)
  @EnvironmentObject private var routerProxy: RouterProxy
  
  init(_ value: any Hashable, active: Bool = false, _ label: @escaping () -> Content) {
    self.value = value
    self.active = active
    self.label = label
  }
  
  init(value: any Hashable, active: Bool = false, _ label: @escaping () -> Content) {
    self.value = value
    self.active = active
    self.label = label
  }
  
  var body: some View {
    WListButton(showArrow: true, active: active) {
      routerProxy.router.path.append(value)
    } label: {
      label()
    }
  }
}

struct WSNavigationLink: View {
  var value: any Hashable
  var active: Bool = false
  var icon: String? = nil
  let label: String
  @EnvironmentObject private var routerProxy: RouterProxy
  
  init(_ value: any Hashable, active: Bool = false, _ label: String, icon: String? = nil) {
    self.value = value
    self.active = active
    self.active = active
    self.label = label
    self.icon = icon
  }
  var body: some View {
    WSListButton(showArrow: true, label, active: active, icon: icon) {
      routerProxy.router.path.append(value)
    }
  }
}

struct WNavLinkButtonStyle: ButtonStyle {
  var active = false
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .overlay(Rectangle().fill(.primary.opacity(configuration.isPressed || (!IPAD && active) ? 0.1 : 0)).animation(.default.speed(2), value: active))
  }
}
