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
  @State private var forcedActive = false
  @State private var uuid = UUID()
  @EnvironmentObject private var routerProxy: RouterProxy
  
  init(showArrow: Bool = false, active: Bool = false, _ action: @escaping () -> (), @ViewBuilder label: @escaping () -> Content) {
    self.active = active
    self.action = action
    self.label = label
    self.showArrow = showArrow
  }
  
  var body: some View {
    Button {
      forcedActive = true
      doThisAfter(0) {
        action()
      }
      doThisAfter(1) {
        forcedActive = false
      }
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
      .contentShape(Rectangle())
    }
    .themedListRow(active: forcedActive || active, isButton: !showArrow)
    .onAppear { withAnimation { forcedActive = false } }
//    .id("\(uuid.uuidString)-\(pressed ? "pressed" : "")")
//    .themedListRowBG(enablePadding: true, disableBG: true, active: active)
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
    self.label = label
    self.icon = icon
  }
  var body: some View {
    WListButton(showArrow: true, active: active) {
      routerProxy.router.path.append(value)
    } label: {
      if let icon = icon {
        Label(label, systemImage: icon)
          .labelStyle(NormalLabelStyle())
      } else {
        Text(label)
      }
    }
  }
}


struct NormalLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label {
      configuration.title.foregroundStyle(.primary)
    } icon: {
      configuration.icon.foregroundStyle(Color.accentColor)
    }
    .labelStyle(.automatic)
  }
}
