//
//  GeneralPanel.swift
//  winston
//
//  Created by Daniel Inama on 17/08/23.
//

import SwiftUI
import Defaults
import WebKit

struct GeneralPanel: View {
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @State private var totalCacheSize: String = ""
  @Environment(\.useTheme) private var theme
  
  var body: some View {
    List{
      Section("Advanced") {
        
        WListButton {
          resetPreferences()
        } label: {
          Label("Reset preferences", systemImage: "trash")
            .foregroundColor(.red)
        }
        
        WListButton {
          clearCache()
          resetCaches()
          resetCoreData()
        } label: {
          Label("Clear Cache (" + totalCacheSize + ")", systemImage: "trash")
            .foregroundColor(.red)
        }
        .onAppear{
          calculateTotalCacheSize()
        }
        
        WListButton {
          likedButNotSubbed = []
        } label: {
          Label("Clear " + String(likedButNotSubbed.count) + " Local Favorites", systemImage: "heart.slash.fill")
            .foregroundColor(.red)
        }
        
      }
      .themedListDividers()
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("General")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  func calculateTotalCacheSize() {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    let temporarySize = calculateDirectorySize(directory: temporaryDirectory)
    let cacheSize = calculateDirectorySize(directory: cacheDirectory)
    
    let totalSize = temporarySize + cacheSize
    let formattedSize = ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    
    totalCacheSize = formattedSize
  }
  
  func calculateDirectorySize(directory: URL?) -> Int {
    guard let directory = directory else {
      return 0
    }
    
    let fileManager = FileManager.default
    var totalSize = 0
    
    if let fileURLs = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.totalFileAllocatedSizeKey], options: [], errorHandler: nil) {
      for case let fileURL as URL in fileURLs {
        do {
          let resourceValues = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
          if let fileSize = resourceValues.totalFileAllocatedSize {
            totalSize += fileSize
          }
        } catch {
          print("Error calculating file size: \(error.localizedDescription)")
        }
      }
    }
    
    return totalSize
  }
  
  func clearCache() {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    clearDirectory(directory: temporaryDirectory)
    clearDirectory(directory: cacheDirectory)
    
    totalCacheSize = "0 bytes"
    print("Cache cleared successfully.")
  }
  
  func clearDirectory(directory: URL?) {
    guard let directory = directory else {
      return
    }
    
    let fileManager = FileManager.default
    
    do {
      let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      
      for fileURL in fileURLs {
        try fileManager.removeItem(at: fileURL)
      }
    } catch {
      print("Error deleting files in directory: \(error.localizedDescription)")
    }
  }
}


