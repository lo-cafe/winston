//
//  CommentSwipePanel.swift
//  winston
//
//  Created by Igor Marcossi on 11/08/23.
//

import SwiftUI
import Defaults

struct CommentSwipePanel: View {
  @Default(.commentSwipeActions) private var commentSwipeActions
  
    var body: some View {
      List {
        
        Picker(selection: $commentSwipeActions.leftFirst) {
          ForEach(allCommentSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Drag left", image: "dragLeft")
        }
        
        Picker(selection: $commentSwipeActions.rightFirst) {
          ForEach(allCommentSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Drag right", image: "dragRight")
        }
        
        Picker(selection: $commentSwipeActions.leftSecond) {
          ForEach(allCommentSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Long drag left", image: "longDragLeft")
        }
        
        Picker(selection: $commentSwipeActions.rightSecond) {
          ForEach(allCommentSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Long drag right", image: "longDragRight")
        }
        
      }
      .navigationTitle("Comments swipe settings")
      .navigationBarTitleDisplayMode(.inline)
    }
}
