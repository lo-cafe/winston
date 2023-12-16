//
//  CommentSwipePanel.swift
//  winston
//
//  Created by Igor Marcossi on 11/08/23.
//

import SwiftUI
import Defaults

struct CommentSwipePanel: View {
  @Default(.CommentLinkDefSettings) private var commentLinkDefSettings
  @Environment(\.useTheme) private var theme
  var body: some View {
    List {
      
      Section {
        Group {
          Picker(selection: $commentLinkDefSettings.swipeActions.leftFirst) {
            ForEach(allCommentSwipeActions) { act in
              Label(act.label, systemImage: act.icon.normal)
                .tag(act)
            }
          } label: {
            Label("Drag Left", image: "dragLeft")
          }
          
          Picker(selection: $commentLinkDefSettings.swipeActions.rightFirst) {
            ForEach(allCommentSwipeActions) { act in
              Label(act.label, systemImage: act.icon.normal)
                .tag(act)
            }
          } label: {
            Label("Drag Right", image: "dragRight")
          }
          
          Picker(selection: $commentLinkDefSettings.swipeActions.leftSecond) {
            ForEach(allCommentSwipeActions) { act in
              Label(act.label, systemImage: act.icon.normal)
                .tag(act)
            }
          } label: {
            Label("Long Drag Left", image: "longDragLeft")
          }
          
          Picker(selection: $commentLinkDefSettings.swipeActions.rightSecond) {
            ForEach(allCommentSwipeActions) { act in
              Label(act.label, systemImage: act.icon.normal)
                .tag(act)
            }
          } label: {
            Label("Long Drag Right", image: "longDragRight")
          }
        }
//        .themedListRowLikeBG(enablePadding: true, disableBG: true)
      }
      .themedListSection()
      
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("Comments Swipe Settings")
    .navigationBarTitleDisplayMode(.inline)
  }
}
