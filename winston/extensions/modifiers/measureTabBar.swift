//
//  measureTabBar.swift
//  winston
//
//  Created by Igor Marcossi on 09/12/23.
//

import SwiftUI

struct TabBarMeasurerAccessor: UIViewControllerRepresentable {
  @Binding var tabBarHeight: Double?
  private let proxyController = ViewController()
  
  func updateTabBarHeight(_ height: Double) {
    tabBarHeight = height
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarMeasurerAccessor>) -> UIViewController {
    proxyController.callback = updateTabBarHeight
    return proxyController
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarMeasurerAccessor>) { }
  
  typealias UIViewControllerType = UIViewController
  
  private class ViewController: UIViewController {
    var callback: (Double) -> Void = { _ in }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      if let tabBar = self.tabBarController {
        Task(priority: .background) {
          self.callback(tabBar.tabBar.bounds.height - getSafeArea().bottom)
        }
      }
    }
  }
}

extension View {
  func measureTabBar(_ tabBarHeight: Binding<Double?>) -> some View {
    self
      .background(TabBarMeasurerAccessor(tabBarHeight: tabBarHeight))
  }
}
