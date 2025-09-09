//
//  MultiredditPicker.swift
//  winston
//
//  Created by Víctor Manuel Puga Ruiz on 08/09/25.
//

import CoreData
import Defaults
import SwiftUI

struct MultiredditPicker: View {
  @FetchRequest(
    entity: CachedMulti.entity(),
    sortDescriptors: [],
  ) var multis: FetchedResults<CachedMulti>

  @Default(.BehaviorDefSettings) var behaviorDefSettings

  var body: some View {
    Picker("Default Multireddit", selection: $behaviorDefSettings.preferenceDefaultFeedName) {
      ForEach(multis) { multi in
        Text(multi.name ?? "Unknown")
          .tag(multi.path ?? "")
      }

      Text("None")
        .tag("")
    }
  }
}
