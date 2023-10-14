//
//  urlCleaner.swift
//  winston
//
//  Created by Daniel Inama on 23/09/23.
//

import Foundation

func cleanURL(url: URL, showPath: Bool = true) -> String {
  var newURL = ""
  
  // Extract the host from the URL and remove "www." prefix if present
  if let host = url.host?.replacingOccurrences(of: "www.", with: "") {
    newURL = host
  }
  
  // Optionally add the path
  if showPath {
    if !url.path.isEmpty {
      newURL += url.path()
    }
  }
  
  // Handle cases where both host and path are empty
  if newURL.isEmpty {
    newURL = "Invalid URL"
  }
  
  return newURL
}

