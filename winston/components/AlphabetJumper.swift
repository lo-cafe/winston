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
  @State private var scrollLetter = ""
  @State private var haptic = UIImpactFeedbackGenerator(style: .rigid)
  
  func goToLetter(_ letter: String, _ disableState: Bool = false) {
    if letter != scrollLetter {
      if !disableState {
        withAnimation(spring) {
          scrollLetter = letter
        }
      }
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
    .fontSize(11, .semibold)
    .frame(width: 16, alignment: .trailing)
    .background(Color(uiColor: UIColor.systemGroupedBackground))
    .contentShape(Rectangle())
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { val in
          let stepI = Int(val.location.y / 15.3)
          if stepI >= letters.count || stepI < 0 { return }
          if letters.count - 1 >= stepI {
            let newLetter = letters[stepI]
            goToLetter(newLetter)
          }
        }
        .onEnded({ _ in withAnimation(spring) { scrollLetter = "" } })
    )
    .frame(height: UIScreen.screenHeight, alignment: .trailing)
    .ignoresSafeArea()
    .foregroundColor(.blue)
  }
}
