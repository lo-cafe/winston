//
//  Settings.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
//import SceneKit

struct Settings: View {
  @Environment(\.openURL) var openURL
  var body: some View {
    GoodNavigator {
      VStack {
        List {
          
          Section {
            NavigationLink {
              BehaviorPanel()
            } label: {
              Label("Behavior", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
            }
            NavigationLink {
              AppearancePanel()
            } label: {
              Label("Appearance", systemImage: "theatermask.and.paintbrush.fill")
            }
            NavigationLink {
              AccountPanel()
            } label: {
              Label("Account", systemImage: "person.crop.circle")
            }
          }
          
          Section {
            NavigationLink {
              AboutPanel()
            } label: {
              Label("About", systemImage: "cup.and.saucer.fill")
            }
            Button {
              sendCustomEmail()
            } label: {
              Label("Report a bug", systemImage: "ladybug.fill")
            }
            
          }
        }
      }
      .navigationTitle("Settings")
    }
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
