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

class Nav: ObservableObject, Identifiable, Codable {
  static let shared = Nav()
  static let router = Nav.shared.activeRouter
  
  /* <Util static functions for ease of use> */
  static func back() { Nav.shared.activeRouter.goBack() }
  static func to(_ dest: Router.NavDest, _ reset: Bool = false) { Nav.shared.activeRouter.navigateTo(dest, reset) }
  static func fullTo(_ tab: TabIdentifier, _ dest: Router.NavDest, _ reset: Bool = false) { Nav.shared.navigateTo(tab, dest, reset) }
  static func present(_ content: PresentingSheet) { Nav.shared.presentingSheet = content }
  static func resetStack() { Nav.shared.activeRouter.resetNavPath() }
  /* </Util static functions for ease of use> */
  
  static private func newRouterForTab(_ tab: TabIdentifier, _ id: UUID) -> Router { Router(id: "\(tab.rawValue)TabRouter-\(id.uuidString)") }
    
  enum TabIdentifier: String, Codable, Hashable, CaseIterable {
    case posts, inbox, me, search, settings
  }
  
  enum PresentingSheet: Codable, Hashable, Identifiable {
    case tipJar
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
  @Published var activeTab: TabIdentifier
  private var routers: [TabIdentifier:Router]
  @Published var presentingSheetsQueue: [PresentingSheet] = []
  var presentingSheet: PresentingSheet? {
    get { presentingSheetsQueue.isEmpty ? nil : presentingSheetsQueue[0] }
    set { if let newValue = newValue { presentingSheetsQueue.insert(newValue, at: 0) } else if !presentingSheetsQueue.isEmpty { presentingSheetsQueue.removeFirst() } }
  }
  private var cancellables = Set<AnyCancellable>()

  
  private init(activeTab: TabIdentifier = .posts) {
    let id = UUID()
    self.id = id
    self.activeTab = activeTab
    self.routers = Dictionary(uniqueKeysWithValues: TabIdentifier.allCases.map { ($0, Self.newRouterForTab($0, id)) })
    
    self.routers.values.forEach { router in
      router.$isAtRoot.sink { _ in
          self.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
  }
  
  var activeRouter: Router { Nav.shared[activeTab] }
  
  
  func navigateTo(_ tab: TabIdentifier, _ dest: Router.NavDest, _ reset: Bool = true) {
    routers[tab]?.navigateTo(dest, reset)
    activeTab = tab
  }
  
  func resetStack() { activeRouter.resetNavPath() }
  
  subscript(tab: TabIdentifier) -> Router {
    if self.routers[tab] == nil { self.routers[tab] = Self.newRouterForTab(tab, id) }
    return self.routers[tab]!
  }
  
  enum CodingKeys: String, CodingKey {
    case id, activeTab, routers
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(activeTab, forKey: .activeTab)
    try container.encode(routers, forKey: .routers)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.activeTab = try container.decode(TabIdentifier.self, forKey: .activeTab)
    self.routers = try container.decode([TabIdentifier:Router].self, forKey: .routers)
  }
  
  static func == (lhs: Nav, rhs: Nav) -> Bool {
    lhs.id == rhs.id
  }
  
  static func openURL(_ url: URL) {
    if url.scheme?.lowercased().contains(/http(s)?/) == true {
      let vc = SFSafariViewController(url: url)
      UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
    } else {
       UIApplication.shared.open(url)
    }
  }


  static func openURL(_ urlStr: String) {
    if let url = URL(string: urlStr)  {
      if url.scheme?.lowercased().contains(/http(s)?/) == true {
        let vc = SFSafariViewController(url: url)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
      } else {
        UIApplication.shared.open(url)
      }
    }
  }
}
