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
    var body: some View {
      List{
        Section("Advanced"){
          Button{
            WebCacheCleaner.clear()
            
          } label: {
            Label("Clear Cache " + String(URLCache.shared.currentDiskUsage), systemImage: "trash")
          }
          Button{
            likedButNotSubbed = []
          } label: {
            Label("Clear " + String(likedButNotSubbed.count) + " Local Favorites", systemImage: "heart.slash.fill")
          }
        }
      }
    }
}

final class WebCacheCleaner {

    class func clear() {
        URLCache.shared.removeAllCachedResponses()

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }

}
