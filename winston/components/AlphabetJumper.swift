//
//  AlphabetJumper.swift
//  winston
//
//  Created by Igor Marcossi on 14/08/23.
//

import SwiftUI

struct AlphabetJumper: View {
  var letters: [String]
  var proxy: ScrollViewProxy
  @GestureState private var scrollLetter = ""
  @State private var haptic = UIImpactFeedbackGenerator(style: .rigid)
  
  func goToLetter(_ letter: String, _ disableState: Bool = false) {

  }
  
  func scrollTo(_ letter: String) {
    if !letter.isEmpty {
      proxy.scrollTo(letter, anchor: .center)
      haptic.prepare()
      haptic.impactOccurred()
    }
  }
  var body: some View {
    VStack(spacing: 0) {
      ForEach(letters, id: \.self) { letter in
        Text(letter.uppercased())
          .allowsHitTesting(false)
          .offset(x: scrollLetter == letter ? -48 : 0)
          .padding(.vertical, 1)
          .padding(.trailing, 2)
          .contentShape(Rectangle())
          .highPriorityGesture(TapGesture().onEnded { goToLetter(letter, true) })
      }
    }
    .animation(spring, value: scrollLetter.isEmpty)
    .fontSize(11, .semibold)
    .frame(width: 16, alignment: .trailing)
//    .background(Color(uiColor: UIColor.systemGroupedBackground))
    .background(Color.clear)
    .contentShape(Rectangle())
    .highPriorityGesture(
      DragGesture(minimumDistance: 0)
        .updating($scrollLetter) { val, state, trans in
          let stepI = Int(val.location.y / 15.3)
          if stepI >= letters.count || stepI < 0 { return }
          if letters.count - 1 >= stepI {
            let newLetter = letters[stepI]
            if newLetter != state {
              trans.animation = spring
              state = newLetter
            }
          }
        }
    )
    .onChange(of: scrollLetter, perform: scrollTo)
    .frame(height: UIScreen.screenHeight, alignment: .trailing)
    .ignoresSafeArea()
    .foregroundStyle(Color.accentColor)
  }
}
