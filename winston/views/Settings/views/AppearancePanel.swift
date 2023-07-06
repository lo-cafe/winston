//
//  Appearance.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct AppearancePanel: View {
  @Default(.preferenceShowPostsAvatars) var preferenceShowPostsAvatars
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.preferenceShowCommentsAvatars) var preferenceShowCommentsAvatars
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
    var body: some View {
      List {
        Section("Posts") {
          Toggle("Show avatars", isOn: $preferenceShowPostsAvatars)
          Toggle("Show cards", isOn: $preferenceShowPostsCards)
        }
        Section("Comments") {
          Toggle("Show avatars", isOn: $preferenceShowCommentsAvatars)
          Toggle("Show cards", isOn: $preferenceShowCommentsCards)
        }
      }
      .navigationTitle("Appearance")
      .navigationBarTitleDisplayMode(.inline)
    }
}
//
//struct Appearance_Previews: PreviewProvider {
//    static var previews: some View {
//        Appearance()
//    }
//}
