//
//  Changelogger.swift
//  winston
//
//  Created by Igor Marcossi on 23/02/24.
//

import SwiftUI

struct ChangeloggerProvider<C: View>: View {
  @ViewBuilder var content: () -> C
  
//  @State private var showing = false
  @State private var releases: [ChangelogRelease]? = nil
  var body: some View {
    ZStack {
      content()
      
      if let releases {
        Changelogger(releases: releases)
      }
    }
    .ignoresSafeArea(.all)
    .onAppear {
#if DEBUG
      let changelogFile = "alpha"
#elseif ALPHA
      let changelogFile = "alpha"
#elseif BETA
      let changelogFile = "beta"
#else
      let changelogFile = "production"
#endif
      
      doThisAfter(0.5) {
        if let url = Bundle.main.url(forResource: changelogFile, withExtension: "json", subdirectory: "changelogs") {
          do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let changelogReleases = try decoder.decode([ChangelogRelease].self, from: data)
            
            releases = changelogReleases
          } catch {
            print(error)
          }
        }
      }
      
    }
  }
}

struct ChangelogRelease: Codable, Identifiable, Hashable, Equatable {
  static func == (lhs: ChangelogRelease, rhs: ChangelogRelease) -> Bool {
    return lhs.id == rhs.id
  }
  var id: String { self.version }
  let version: String
  let timestamp: Double
  let report: ChangelogReleaseReport
  
  struct ChangelogReleaseReport: Codable, Hashable, Equatable {
    var fix: [ChangelogReportChange]?
    var feat: [ChangelogReportChange]?
    var others: [ChangelogReportChange]?
    
    struct ChangelogReportChange: Codable, Hashable, Equatable, Identifiable {
      var id: String { (self.icon ?? "") + self.subject + self.description }
      let icon: String?
      let subject: String
      let description: String
    }
  }
}

