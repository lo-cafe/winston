//
//  Changelogger.swift
//  winston
//
//  Created by Igor Marcossi on 23/02/24.
//

import SwiftUI

struct ChangeloggerProvider<C: View>: View {
  @ViewBuilder var content: () -> C
  
  @State private var showing = false
  var body: some View {
    ZStack {
      content()
        .blur(radius: showing ? 40 : 0, opaque: true)
        .saturation(showing ? 2 : 1)
    }
    .ignoresSafeArea(.all)
    .onAppear {
#if DEBUG
      var changelogFile = "alpha"
#elseif ALPHA
      var changelogFile = "alpha"
#elseif BETA
      var changelogFile = "beta"
#else
      var changelogFile = "production"
#endif
      
      if let url = Bundle.main.url(forResource: changelogFile, withExtension: "json", subdirectory: "changelogs") {
        do {
          let data = try Data(contentsOf: url)
          let decoder = JSONDecoder()
          let changelogRelease = try decoder.decode(ChangelogRelease.self, from: data)
          print(changelogRelease) // Use the changelogRelease struct as needed
        } catch {
          print(error)
        }
      }
      
//      withAnimation(.spring) { showing = true }
    }
  }
}

struct ChangelogRelease: Codable {
  let version: String
  let timestamp: Double
  let report: ChangelogReleaseReport
  
  struct ChangelogReleaseReport: Codable {
    var fix: [ChangelogReportChange]?
    var feat: [ChangelogReportChange]?
    var others: [ChangelogReportChange]?
    
    struct ChangelogReportChange: Codable {
      let icon: String?
      let subject: String
      let description: String
    }
  }
}

