//
//  SwipeAnywhere.swift
//  winston
//
//  Created by Igor Marcossi on 16/08/23.
//

import SwiftUI
import Defaults

extension View {
  func swipeAnywhere(size: CGSize, activeTab: Nav.TabIdentifier) -> some View {
    FullSwipeNavigationStack(activeTab: activeTab, size: size, content: self)
  }
}

struct FullSwipeNavigationStack<C: View>: UIViewControllerRepresentable, Equatable {
  static func == (lhs: FullSwipeNavigationStack<C>, rhs: FullSwipeNavigationStack<C>) -> Bool {
    return lhs.activeTab == rhs.activeTab
  }
  
  var activeTab: Nav.TabIdentifier
  var size: CGSize
  var content: C
  
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
  
  func makeUIViewController(context: Context) -> UIHostingController<C> {
    let hostingController = UIHostingController<C>(rootView: content)
    setupConstraints(hostingController.view)
    hostingController.view.frame.size = self.size
    hostingController.view.isOpaque = false
    hostingController.view.isUserInteractionEnabled = true
    hostingController.view.backgroundColor = .clear
    hostingController.view.isExclusiveTouch = false
    hostingController.view.isMultipleTouchEnabled = true
    return hostingController
  }
  
  func updateUIViewController(_ hostingController: UIHostingController<C>, context: Context) {
    setupConstraints(hostingController.view)
    let newSize = self.size
    hostingController.view.frame.size = newSize
    
    if context.coordinator.prevActiveTab == activeTab { return }
    context.coordinator.prevActiveTab = activeTab
    
    hostingController.view.gestureRecognizers?.forEach { gesture in
      hostingController.view.removeGestureRecognizer(gesture)
    }

    hostingController.view.addGestureRecognizer(Nav.shared.activeRouter.navController.tabBarGesture)
    hostingController.view.addGestureRecognizer(UITapGestureRecognizer())
    hostingController.rootView = content

  }
  
    class Coordinator: NSObject {
      var prevActiveTab: Nav.TabIdentifier? = nil
    }
}
