//
//  Behavior.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct BehaviorPanel: View {
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @Default(.openYoutubeApp) var openYoutubeApp
  @Default(.preferredSort) var preferredSort
  
  var body: some View {
    List {
      Section {
        Toggle("Open Youtube videos externally", isOn: $openYoutubeApp)

        Picker("Default posts sorting", selection: $preferredSort) {
          ForEach(SubListingSortOption.allCases, id: \.self) { val in
            HStack(spacing: 8) {
              Image(systemName: val.rawVal.icon)
              Text(val.rawVal.id.capitalized)
            }
            .fixedSize()
          }
        }
        
        VStack(alignment: .leading) {
          HStack {
            Text("Max posts image height")
            Spacer()
            Text(maxPostLinkImageHeightPercentage == 110 ? "Original" : "\(Int(maxPostLinkImageHeightPercentage))%")
              .opacity(0.6)
          }
          Slider(value: $maxPostLinkImageHeightPercentage, in: 10...110, step: 10)
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
