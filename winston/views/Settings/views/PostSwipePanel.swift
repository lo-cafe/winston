//
//  PostSwipePanel.swift
//  winston
//
//  Created by Igor Marcossi on 11/08/23.
//

import SwiftUI
import Defaults

struct PostSwipePanel: View {
  @Default(.postSwipeActions) private var postSwipeActions
  
    var body: some View {
      List {
        
        Picker(selection: $postSwipeActions.leftFirst) {
          ForEach(allPostSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Drag left", image: "dragLeft")
        }
        
        Picker(selection: $postSwipeActions.rightFirst) {
          ForEach(allPostSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Drag right", image: "dragRight")
        }
        
        Picker(selection: $postSwipeActions.leftSecond) {
          ForEach(allPostSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Long drag left", image: "longDragLeft")
        }
        
        Picker(selection: $postSwipeActions.rightSecond) {
          ForEach(allPostSwipeActions) { act in
            Label(act.label, systemImage: act.icon.normal)
              .tag(act)
          }
        } label: {
          Label("Long drag right", image: "longDragRight")
        }
        
      }
      .navigationTitle("Posts swipe settings")
      .navigationBarTitleDisplayMode(.inline)
    }
}
