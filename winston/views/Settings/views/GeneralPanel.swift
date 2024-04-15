//
//  GeneralPanel.swift
//  winston
//
//  Created by Daniel Inama on 17/08/23.
//

import SwiftUI
import Defaults
import Nuke
import WebKit
import UniformTypeIdentifiers

struct GeneralPanel: View {
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @Default(.BehaviorDefSettings) var behaviorDefSettings
  @Default(.GeneralDefSettings) var generalDefSettings
  @State private var totalCacheSize: String = ""
  @Environment(\.useTheme) private var theme
  @State var isMoving: Bool = false
  @State var settingsFileURL: String = ""
  @State var doImport: Bool = false
  var body: some View {
    List{
      
      Group {
        
        Section {
          Toggle("Sync credentials", systemImage: "person.2.badge.key.fill", isOn: $behaviorDefSettings.iCloudSyncCredentials)
//          Toggle("Sync preferences", systemImage: "slider.horizontal.3", isOn: $generalDefSettings.iCloudSyncUserDefaults)
//            .onChange(of: generalDefSettings.iCloudSyncUserDefaults) { _, new in
//              Zephyr.syncUbiquitousKeyValueStoreOnChange = new
//            }
//          WListButton {
//            print(NSUbiquitousKeyValueStore.default.dictionaryRepresentation["ZephyrSyncKey"])
//            print(UserDefaults.standard.dictionaryRepresentation()["ZephyrSyncKey"])
////            Zephyr.sync()
//          } label: {
//            Label("Force preferences sync", systemImage: "arrow.clockwise")
//          }
        } header: {
          Text("iCloud")
        } footer: {
          Text("Syncing will run on every app restart and on every preference change. Preferences also include themes.")
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
            Label("Export Settings", systemImage: "arrowshape.turn.up.left")
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
    (try? DataCache(name: "lo.cafe.winston.datacache"))?.flush()
    Nuke.ImageCache.shared.removeAll()
    Nuke.DataLoader.sharedUrlCache.removeAllCachedResponses()
    (ImagePipeline.shared.configuration.dataLoader as? DataLoader)?.session.configuration.urlCache?.removeAllCachedResponses()
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    
    flushFilesInDirectoryButNotFolders(temporaryDirectory)
    flushFilesInDirectoryButNotFolders(cacheDirectory)
    resetCoreData()
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



func flushFilesInDirectoryButNotFolders(_ at: URL?) {
  guard let at = at else { return }
  let fileManager = FileManager.default
  guard let enumerator = fileManager.enumerator(at: at, includingPropertiesForKeys: nil) else { return }
  
  for case let file as String in enumerator {
    let path = at.appendingPathComponent(file)
    var isDirectory: ObjCBool = false
    
    if fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory) {
      if !isDirectory.boolValue {
        do {
          try fileManager.removeItem(at: path)
        } catch let error as NSError {
          print("Error: \(error.localizedDescription)")
        }
      }
    }
  }
}
