//
//  decodePostToCache.swift
//  winston
//
//  Created by Igor Marcossi on 21/09/23.
//

import Foundation

func decodePostToCache(id: String, str: String?) {
  if let str = str {
    doIt(id: id, str: str)
  }
}

private func doIt(id: String, str: String) {
    Caches.postsAttrStr.addKeyValue(key: id) {
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: str.data(using: .utf8)!)) ?? AttributedString()
      return jsonData
    }
}
