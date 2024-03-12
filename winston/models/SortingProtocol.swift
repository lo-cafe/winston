//
//  SortingProtocol.swift
//  winston
//
//  Created by Igor Marcossi on 24/01/24.
//

import Foundation
import Defaults

protocol Sorting: Codable, CaseIterable, Identifiable, Defaults.Serializable, Hashable {
  var id: String { get }
  var meta: SortingOption { get }
  var valueWithParent: (any Sorting)? { get }
}

extension Sorting {
  var id: String { self.meta.apiValue }
  var valueWithParent: (any Sorting)? { nil }
}

struct SortingOption {
  let icon: String
  let label: String
  let apiValue: String
  var children: [(any Sorting)]? = nil
}

