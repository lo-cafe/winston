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

func rootURL(_ str: String) -> URL? {
  if let url = URL(string: str) {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.query = nil
    return components?.url
  }
  return nil
}

func rootURLString(_ url: String) -> String? {
  if let urlURL = URL(string: url) {
    var components = URLComponents(url: urlURL, resolvingAgainstBaseURL: false)
    components?.query = nil
    return components?.url?.absoluteString
  }
  return nil
}
