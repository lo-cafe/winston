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
  @Default(.replyModalBlurBackground) var replyModalBlurBackground
  @Default(.newPostModalBlurBackground) var newPostModalBlurBackground
    var body: some View {
      List {
        Section("General") {
          Toggle("Blur reply modal background", isOn: $replyModalBlurBackground)
        }
        Section("Posts") {
          Toggle("Show avatars", isOn: $preferenceShowPostsAvatars)
          Toggle("Show cards", isOn: $preferenceShowPostsCards)
          Toggle("Blur new posts background", isOn: $newPostModalBlurBackground)
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
