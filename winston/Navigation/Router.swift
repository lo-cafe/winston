//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI
import Combine

class ViewControllerHolder {
  let globalGesture: UIPanGestureRecognizer
  let tabBarGesture: UIPanGestureRecognizer
  var controller: UIViewController? {
    didSet {
      controller?.navigationController?.addFullSwipeGesture(globalGesture)
      controller?.navigationController?.addFullSwipeGesture(tabBarGesture)
    }
  }
  
  init(routerID: String) {
    let gesture = UIPanGestureRecognizer()
    gesture.name = "swipe-anywhere-gesture:router-\(routerID)"
    gesture.isEnabled = true
    gesture.cancelsTouchesInView = false
    let tabBarGesture = UIPanGestureRecognizer()
    tabBarGesture.name = "swipe-tabbar-gesture:router-\(routerID)"
    tabBarGesture.isEnabled = true
    tabBarGesture.cancelsTouchesInView = false
    self.globalGesture = gesture
    self.tabBarGesture = tabBarGesture
  }
  
  var isGestureEnabled: Bool {
    get { globalGesture.isEnabled }
    set { globalGesture.isEnabled = newValue }
  }
  
  func addGestureToViews() {
    removeGestureFromViews();
    controller?.navigationController?.view.addGestureRecognizer(globalGesture)
  }
  
  func removeGestureFromViews() {
    if let existingGesture = controller?.navigationController?.view.gestureRecognizers?.first(where: { $0.name == (globalGesture.name ?? "none") }) {
      controller?.navigationController?.view.removeGestureRecognizer(existingGesture)
    }
  }
}

@Observable
class Router: Hashable, Equatable, Identifiable {
  let id: String
  
  var firstSelected: NavDest? {
    get { fullPath.isEmpty ? nil : fullPath[0] }
    set {
      if let newValue = newValue {
        print(fullPath.count)
        if fullPath.count == 0 { fullPath.append(newValue) } else { fullPath[0] = newValue } } else { fullPath = [] }
    }
  }
  var fullPath: [NavDest] = []
  var path: [NavDest] {
    get { Array(self.fullPath.dropFirst()) }
    set {
      if fullPath.isEmpty { self.fullPath = newValue } else { self.fullPath = [fullPath[0]] + newValue }
    }
  }
  private(set) var isAtRoot = false {
    willSet {
      self.navController.isGestureEnabled = !newValue
    }
  }
  var navController: ViewControllerHolder
  
  private var cancellables = Set<AnyCancellable>()
  
  init(id: String) {
    self.id = id
    self.navController = ViewControllerHolder(routerID: id)
//    $fullPath.map { $0.isEmpty }.assign(to: \.isAtRoot, on: self).store(in: &cancellables)
  }
  
  func goBack() { _ = withAnimation { self.fullPath.removeLast() } }
  func resetNavPath() { withAnimation { self.fullPath.removeAll() } }
  func navigateTo(_ dest: NavDest, _ reset: Bool = false) { self.path = reset ? [dest] : self.path + [dest] }
  
  enum NavDest: Hashable, Codable, Identifiable {
    var id: String {
      switch self {
      case .reddit(let reddit): return reddit.id
      case .setting(let setting): return setting.id
      }
    }
    case reddit(Reddit)
    case setting(Setting)
    
    enum Reddit: Hashable, Codable, Identifiable {
      var id: String {
        switch self {
        case .post(let post): return post.id
        case .postHighlighted(let post, _): return post.id
        case .subFeed(let subreddit): return subreddit.id
        case .subInfo(let subreddit): return subreddit.id
        case .multiFeed(let multi): return multi.id
        case .multiInfo(let multi): return multi.id
        case .user(let user): return user.id
        }
      }
      case post(Post)
      case postHighlighted(Post, String)
      case subFeed(Subreddit)
      case subInfo(Subreddit)
      case multiFeed(Multi)
      case multiInfo(Multi)
      case user(User)
    }
    enum Setting: String, Hashable, Codable, Identifiable {
      var id: String { self.rawValue }
      case behavior, appearance, credentials, about, commentSwipe, postSwipe, accessibility, faq, general, themes, filteredSubreddits, appIcon, themeStore
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case id, firstSelected, path
  }
  
  static func == (lhs: Router, rhs: Router) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(firstSelected)
    hasher.combine(path)
  }
}

extension UINavigationController {
    func addFullSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
    }
}
