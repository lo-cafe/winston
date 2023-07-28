//
//  rootURL.swift
//  winston
//
//  Created by Igor Marcossi on 28/07/23.
//

import Foundation

func rootURL(_ url: URL) -> URL? {
  var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
  components?.query = nil
  return components?.url
}
