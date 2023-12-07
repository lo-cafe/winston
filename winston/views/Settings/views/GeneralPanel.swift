//
//  GeneralPanel.swift
//  winston
//
//  Created by Daniel Inama on 17/08/23.
//

import SwiftUI
import Defaults
import WebKit
import UniformTypeIdentifiers

struct GeneralPanel: View {
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @Default(.syncKeyChainAndSettings) var syncKeyChainAndSettings
  @State private var totalCacheSize: String = ""
  @Environment(\.useTheme) private var theme
  @State var isMoving: Bool = false
  @State var settingsFileURL: String = ""
  @State var doImport: Bool = false
  var body: some View {
    List{
      
      Group {
        Section("General"){
          Toggle("Sync API Key", isOn: $syncKeyChainAndSettings)
        }
        
        Section("Backup"){
          WListButton {
            let date = Date()
            let file = exportUserDefaultsToJSON(fileName: "WinstonSettings-" + date.ISO8601Format() + ".json")
            if let file {
              isMoving.toggle()
              settingsFileURL = file
            }
          } label: {
            HStack {
              Image(systemName: "arrowshape.turn.up.left")
              Text("Export Settings").foregroundStyle(Color.accentColor)
            }
          }
          .fileMover(isPresented: $isMoving, file: URL(string: settingsFileURL), onCompletion: { completion in
            //          print(completion)
          })
          
          WListButton {
            doImport.toggle()
          } label: {
            Label("Import Settings", systemImage: "square.and.arrow.down")
          }.fileImporter(isPresented: $doImport, allowedContentTypes: [UTType.json], allowsMultipleSelection: false, onCompletion: { result in
            switch result {
            case .success(let file):
              let success = importUserDefaultsFromJSON(jsonFilePath: file[0])
              if success {
                print("success")
              } else {
                print("error")
              }
            case .failure(let error):
              print(error.localizedDescription)
            }
            
          })
        }
        
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
      }
      .themedListSection()
      
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


