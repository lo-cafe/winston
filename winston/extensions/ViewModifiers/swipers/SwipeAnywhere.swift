//
//  SwipeAnywhere.swift
//  winston
//
//  Created by Igor Marcossi on 16/08/23.
//

import SwiftUI
import Defaults
import Combine

struct SwipeAnywhereTrigger: ViewModifier {
  var size: CGSize
  @ObservedObject private var nav = Nav.shared
  func body(content: Content) -> some View {
    FullSwipeNavigationStack(router: nav.activeRouter, size: size) {
      content
    }
  }
}

extension View {
  func swipeAnywhere(size: CGSize) -> some View {
    self.modifier(SwipeAnywhereTrigger(size: size))
  }
}

struct FullSwipeNavigationStack<C: View>: UIViewRepresentable {
  var router: Router
  var size: CGSize
  @ViewBuilder var content: () -> C
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  fileprivate func setupConstraints(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    view.bottomAnchor.constraint (equalTo: view.bottomAnchor).isActive = true
    view.leftAnchor.constraint (equalTo: view.leftAnchor).isActive = true
    view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
  }
  
  func makeUIView(context: Context) -> UIView {
    let hostingController = UIHostingController<C>(rootView: content())
    setupConstraints(hostingController.view)
    hostingController.view.frame.size = self.size
    hostingController.view.isOpaque = false
    hostingController.view.isUserInteractionEnabled = true
    hostingController.view.backgroundColor = .clear
    hostingController.view.isExclusiveTouch = false
    hostingController.view.isMultipleTouchEnabled = true
    return hostingController.view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    if let controller = uiView.parentController as? UIHostingController<C> {
      controller.rootView = content()
    }
    setupConstraints(uiView)
    let newSize = self.size
    uiView.frame.size = newSize
    
    if context.coordinator.prevRouterID == router.id { return }
    uiView.gestureRecognizers?.forEach { gesture in
      uiView.removeGestureRecognizer(gesture)
    }
    uiView.addGestureRecognizer(router.navController.tabBarGesture)
    uiView.addGestureRecognizer(UITapGestureRecognizer())
  }
  
  class Coordinator: NSObject {
    var prevRouterID: String?
  }
}
