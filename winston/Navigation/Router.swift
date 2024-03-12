//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI

class ViewControllerHolder: Identifiable, Equatable {
  static func == (lhs: ViewControllerHolder, rhs: ViewControllerHolder) -> Bool {
    lhs.id == rhs.id
  }
  
  var id: String { "ctrl-holder-\(self.routerID)" }
  let routerID: String
  var globalGesture: UIPanGestureRecognizer
  var tabBarGesture: UIPanGestureRecognizer
  var navController: UINavigationController?
  var controller: UIViewController? {
    willSet {
      if let newController = newValue, controller != newController {
        newController.navigationController?.addFullSwipeGesture(globalGesture)
        newController.navigationController?.addFullSwipeGesture(tabBarGesture)
      }
    }
  }
  
  init(routerID: String) {
    self.routerID = routerID
    self.globalGesture = Self.newGesture("swipe-anywhere-gesture:router-\(routerID)")
    self.globalGesture.isEnabled = false
    self.tabBarGesture = Self.newGesture("swipe-tabbar-gesture:router-\(routerID)")
    self.tabBarGesture.isEnabled = false
  }
  
  static func newGesture(_ id: String) -> UIPanGestureRecognizer {
    let gesture = UIPanGestureRecognizer()
    gesture.name = "\(id)-\(UUID().uuidString)"
    gesture.isEnabled = true
    gesture.cancelsTouchesInView = false
    return gesture
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
        if fullPath.count == 0 { fullPath.append(newValue) } else { fullPath[0] = newValue } } else { fullPath = [] }
    }
  }
  var fullPath: [NavDest] = [] {
    didSet {
      if fullPath.isEmpty != isAtRoot { isAtRoot = fullPath.isEmpty }
    }
  }
  var path: [NavDest] {
    get { Array(self.fullPath.dropFirst()) }
    set {
      if fullPath.isEmpty { self.fullPath = newValue } else { self.fullPath = [fullPath[0]] + newValue }
    }
  }
  private(set) var isAtRoot = true {
    willSet {
      self.navController.tabBarGesture.isEnabled = !newValue
      self.navController.globalGesture.isEnabled = !newValue
    }
  }
  var navController: ViewControllerHolder
    
  init(id: String) {
    self.id = id
    self.navController = ViewControllerHolder(routerID: id)
  }
  
  func goBack() { if self.fullPath.count > 0 { _ = withAnimation { self.fullPath.removeLast() } } }
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
