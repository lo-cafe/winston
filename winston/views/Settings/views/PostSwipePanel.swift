//
//  PostSwipePanel.swift
//  winston
//
//  Created by Igor Marcossi on 11/08/23.
//

import SwiftUI
import Defaults

struct PostSwipePanel: View {
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  @Environment(\.useTheme) private var theme
    var body: some View {
      List {
        
        Section {
          Group {
            Picker(selection: $postLinkDefSettings.swipeActions.leftFirst) {
              ForEach(allPostSwipeActions) { act in
                Label(act.label, systemImage: act.icon.normal)
                  .tag(act)
              }
            } label: {
              Label("Drag Left", image: "dragLeft")
            }
            
            Picker(selection: $postLinkDefSettings.swipeActions.rightFirst) {
              ForEach(allPostSwipeActions) { act in
                Label(act.label, systemImage: act.icon.normal)
                  .tag(act)
              }
            } label: {
              Label("Drag Right", image: "dragRight")
            }
            
            Picker(selection: $postLinkDefSettings.swipeActions.leftSecond) {
              ForEach(allPostSwipeActions) { act in
                Label(act.label, systemImage: act.icon.normal)
                  .tag(act)
              }
            } label: {
              Label("Long Drag Left", image: "longDragLeft")
            }
            
            Picker(selection: $postLinkDefSettings.swipeActions.rightSecond) {
              ForEach(allPostSwipeActions) { act in
                Label(act.label, systemImage: act.icon.normal)
                  .tag(act)
              }
            } label: {
              Label("Long Drag Right", image: "longDragRight")
            }
          }
//          .themedListRowLikeBG(enablePadding: true, disableBG: true)
        }
        .themedListSection()
        
      }
      .themedListBG(theme.lists.bg)
      .navigationTitle("Posts Swipe Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
}
