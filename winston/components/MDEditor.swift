//
//  MDEditor.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import SwiftUI
import HighlightedTextEditor

private let placeholders: [String] = [
  "Say what again, SAY WHAT AGAIN! I dare you, I double dare you...",
  "Look, I get your point, but if we put a ruler in the horizon...",
  "Yesterday I found a horse in my room, then...",
  "This is the best placeholder you'll find...",
  "When you get to Hell, John, tell them Daisy sent you.",
  "I have a dream that one day this nation will rise up...",
  "It's gonna change the world for good. After years we finally found...",
  "The cosmos is within us. We are made of star-stuff. We are...",
  "I like the way you die, boy...",
  "— Don’t you hate that?\n— What?\n— Uncomfortable silences...",
  "All we have to decide is what to do with the time that is given us...",
  "FLY, YOU FOOLS! ...yes, it's fly, not run...",
  "Winston, I mean, Houston, we have a problem!...",
  "I would have gone with you to the end, into the very fires of mordor...",
]

struct MDEditor: View {
  @Binding var text: String
  @State var placeholder: String = placeholders.randomElement()!
    var body: some View {
      ZStack(alignment: .topLeading) {
        if text.isEmpty {
          Text(placeholder)
            .opacity(0.35)
            .padding(.top, 8)
            .padding(.leading, 5)
        }
        TextEditor(text: $text)
          .background(Color.clear)
        // The HighlightedTextEditor package currently does not integrate well with iOS 17's predictive text. It will be disabled until that issue is remedied.
        // HighlightedTextEditor(text: $text, highlightRules: winstonMDEditorPreset)
//          .introspect { editor in
//            editor.textView.backgroundColor = .clear
//          }
      }
      .animation(nil, value: text.isEmpty)
    }
}

