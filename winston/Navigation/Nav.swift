//
//  Nav.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation
import Combine
import SafariServices
import UIKit
import SwiftUI

@Observable
class Nav: Identifiable, Equatable {
  static let shared = Nav()
  
  /* <Util static functions for ease of use> */
  static func back() { Nav.shared.activeRouter.goBack() }
  static func to(_ dest: Router.NavDest, _ reset: Bool = false) { Nav.shared.activeRouter.navigateTo(dest, reset) }
  static func fullTo(_ tab: TabIdentifier, _ dest: Router.NavDest, _ reset: Bool = false) { Nav.shared.navigateTo(tab, dest, reset) }
  static func present(_ content: PresentingSheet?) { Nav.shared.presentingSheet = content }
  static func resetStack() { Nav.shared.activeRouter.resetNavPath() }
  /* </Util static functions for ease of use> */
    
  static private func newRouterForTab(_ tab: TabIdentifier, _ id: UUID) -> Router { Router(id: "\(tab.rawValue)TabRouter-\(id.uuidString)") }
  
  enum TabIdentifier: String, Codable, Hashable, CaseIterable, Identifiable, Equatable {
    var id: String { self.rawValue }
    case posts, inbox, me, search, settings
  }
  
  enum PresentingSheet: Codable, Hashable, Identifiable, Equatable {
    case onboarding
    case editingCredential(RedditCredential)
    case announcement(Announcement)
    case editingTheme(WinstonTheme)
    case sharedTheme(ThemeData)
    
    var id: String {
      var newID: String = ""
      switch self {
      case .announcement(let ann): newID = ann.id
      case .editingCredential(let cred): newID = cred.id.uuidString
      case .tipJar: newID = "tipJar"
      case .onboarding: newID = "onboarding"
      case .editingTheme(let theme): newID = theme.id
      case .sharedTheme(let themeData): newID = themeData.id
      }
      return "\(newID)-presenting-sheet-Nav"
    }
  }
  
  var id: UUID
  var activeTab: TabIdentifier {
    willSet {
      if activeTab == newValue { self.activeRouter.resetNavPath() }
    }
  }
  var routers: [TabIdentifier:Router]
  var presentingSheetsQueue: [PresentingSheet] = []
  var presentingSheet: PresentingSheet? {
    get { presentingSheetsQueue.isEmpty ? nil : presentingSheetsQueue[0] }
    set {
      if let newValue {
        if !presentingSheetsQueue.isEmpty && presentingSheetsQueue.first == newValue {
          presentingSheetsQueue[0] = newValue
        } else {
          presentingSheetsQueue.insert(newValue, at: 0)
        }
      } else if !presentingSheetsQueue.isEmpty { presentingSheetsQueue.removeFirst() }
    }
  }
  var activeRouter: Router { Nav.shared[activeTab] }
  private var cancellables = Set<AnyCancellable>()
  
  
  private init(activeTab: TabIdentifier = .posts) {
    let id = UUID()
    self.id = id
    self.activeTab = activeTab
    self.routers = Dictionary(uniqueKeysWithValues: TabIdentifier.allCases.map { ($0, Self.newRouterForTab($0, id)) })
  }
  
  func navigateTo(_ tab: TabIdentifier, _ dest: Router.NavDest, _ reset: Bool = true) {
    routers[tab]?.navigateTo(dest, reset)
    if tab != activeTab {	activeTab = tab }
  }
  
  func resetStack() { activeRouter.resetNavPath() }
  
  subscript(tab: TabIdentifier) -> Router {
    let router = self.routers[tab] ?? Self.newRouterForTab(tab, id)
    if self.routers[tab] == nil { self.routers[tab] = router }
    return router
  }
  
  enum CodingKeys: String, CodingKey {
    case id, activeTab, routers
  }
  
  static func == (lhs: Nav, rhs: Nav) -> Bool {
    lhs.id == rhs.id
  }
  
  static func openURL(_ url: URL) {
    if url.scheme?.lowercased().contains(/http(s)?/)==true {
      let vc = SFSafariViewController(url: url)
      UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
    } else {
      UIApplication.shared.open(url)
    }
  }
  
  
  static func openURL(_ urlStr: String) {
    if let url = URL(string: urlStr)  {
      openURL(url)
    }
  }
}
