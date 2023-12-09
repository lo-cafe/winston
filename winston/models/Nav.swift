//
//  Nav.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation
import Combine

class Nav: ObservableObject, Identifiable, Codable {
  static let shared = Nav()
  static let router = Nav.shared.activeRouter
  static func back() { Nav.shared.activeRouter.goBack() }
  static func to(_ dest: Router.NavDest, _ reset: Bool = true) { Nav.shared.activeRouter.navigateTo(dest, reset) }
  static func fullTo(_ tab: TabIdentifier, _ dest: Router.NavDest, _ reset: Bool = true) { Nav.shared.navigateTo(tab, dest, reset) }
  static func resetStack() { Nav.shared.activeRouter.resetNavPath() }
  static private func newRouterForTab(_ tab: TabIdentifier, _ id: UUID) -> Router { Router(id: "\(tab.rawValue)TabRouter-\(id.uuidString)") }
  
  var id: UUID
  @Published var activeTab: TabIdentifier
  private var routers: [TabIdentifier:Router]
  private var cancellables = Set<AnyCancellable>()

  
  init(activeTab: TabIdentifier = .posts) {
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
  
  enum TabIdentifier: String, Codable, Hashable, CaseIterable {
    case posts, inbox, me, search, settings
  }
  
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
    let t = defaultTheme.comments
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.activeTab = try container.decode(TabIdentifier.self, forKey: .activeTab)
    self.routers = try container.decode([TabIdentifier:Router].self, forKey: .routers)
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
