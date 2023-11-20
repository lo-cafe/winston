//
//  importTheme.swift
//  winston
//
//  Created by Igor Marcossi on 02/10/23.
//

import Foundation
import Zip
import Defaults

func importTheme(at rawFileURL: URL) -> Bool {
  do {
    let fileManager = FileManager.default
    let docUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    guard let documentDirectory: URL = docUrls.first else {
      print("Error getting directory")
      return false
    }
    let fileURL = documentDirectory.appendingPathComponent("\(UUID().uuidString).zip")
    
    if fileManager.fileExists(atPath: fileURL.path()) {
      try? fileManager.removeItem(at: fileURL)
    }
    
    let gotAccess = rawFileURL.startAccessingSecurityScopedResource()
    if !rawFileURL.path.hasPrefix(NSTemporaryDirectory()) && !gotAccess {
      print("Error getting file access")
      return false
    }
    try? fileManager.copyItem(at: rawFileURL, to: fileURL)
    rawFileURL.stopAccessingSecurityScopedResource()
    let unzipDirectory = try Zip.quickUnzipFile(fileURL)
    let themeJsonURL = unzipDirectory.appendingPathComponent("theme.json")
    let themeData = try Data(contentsOf: themeJsonURL)
    let theme = try JSONDecoder().decode(WinstonTheme.self, from: themeData)
    
    let urls = try fileManager.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: nil)
    let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    for url in urls {
      if url.lastPathComponent != "theme.json" {
        let destinationFileURL = destinationURL.appendingPathComponent(url.lastPathComponent)
        try? fileManager.removeItem(at: destinationFileURL)
        try fileManager.moveItem(at: url, to: destinationFileURL)
      }
    }
    
    DispatchQueue.main.async {
      Defaults[.themesPresets].append(theme)
    }
    
    return true
  } catch {
    print("Failed to unzip file with error: \(error)")
    return false
  }
}
