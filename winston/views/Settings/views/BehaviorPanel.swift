//
//  Behavior.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct BehaviorPanel: View {
  @Default(.preferredSort) var preferredSort

    var body: some View {
      List {
        Section {
          Picker("Default posts sorting", selection: $preferredSort) {
            ForEach(SubListingSortOption.allCases, id: \.self) { val in
              HStack(spacing: 8) {
                Image(systemName: val.rawVal.icon)
                Text(val.rawVal.id.capitalized)
              }
              .fixedSize()
            }
          }
        }
      }
      .navigationTitle("Behavior")
      .navigationBarTitleDisplayMode(.inline)
    }
}
//
//struct Behavior_Previews: PreviewProvider {
//    static var previews: some View {
//        Behavior()
//    }
//}
