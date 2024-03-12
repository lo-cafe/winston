//
//  JSONCoding.swift
//  winston
//
//  Created by Igor Marcossi on 23/11/23.
//

import Foundation

extension Encodable {
  func toStr() -> String? {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(self) {
      return String(data: encoded, encoding: .utf8)
    }
    return nil
  }
}


extension String {
  func toObj<T: Decodable>(_ thing: T.Type) -> T? {
    let decoder = JSONDecoder()
    if let data = self.data(using: .utf8) {
      return try? decoder.decode(thing, from: data)
    }
    return nil
  }
}
