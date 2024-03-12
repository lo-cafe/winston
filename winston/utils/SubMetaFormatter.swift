//
//  SubMetaFormatter.swift
//  winston
//
//  Created by Igor Marcossi on 06/02/24.
//

import Foundation

struct SubMetaFormatter {
  var id: String?
  var fullname: String?
  var name: String?
  
  init(_ id: String) {
    var formattedId = id
    if formattedId.hasPrefix("t2_") {
      self.fullname = formattedId
      formattedId.removeFirst(3)
    } else if formattedId.hasPrefix("_") {
      formattedId.removeFirst()
    }
    self.id = formattedId
    self.fullname = "t2_" + formattedId
  }
  
  init(name: String) {
    var formattedName = name
    if formattedName.hasPrefix("r/") {
      formattedName.removeFirst(2)
    } else if formattedName.hasPrefix("/r/") {
      formattedName.removeFirst(3)
    } else if formattedName.hasPrefix("/"){
      formattedName.removeFirst()
    }
    if formattedName.hasSuffix("/") {
      formattedName.removeLast()
    }
    self.name = formattedName
  }
}
