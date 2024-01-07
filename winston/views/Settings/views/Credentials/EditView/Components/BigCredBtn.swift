//
//  BigCredBtn.swift
//  winston
//
//  Created by Igor Marcossi on 02/01/24.
//

import SwiftUI

struct BigCredBtn<C: View>: View {
  @Binding var nav: NavigationPath
  var img: () -> C
  var title: String
  var description: String
  var page: CredentialEditStack.Mode
  var recommended: Bool = false
  
  var body: some View {
    PressableButton {
      nav.append(page)
    } label: { pressed in
      HStack(alignment: .top, spacing: 10) {
        img()
        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
              Text(title).fontSize(21, .semibold)
              Text(recommended ? "EASY" : "NERD").fontSize(12, .bold).foregroundStyle(recommended ? .white : .primary.opacity(0.5)).padding(EdgeInsets(top: 0.5, leading: 4, bottom: 0.5, trailing: 4)).background(RR(5, recommended ? .teal : .gray.opacity(0.25))).padding(.bottom, -2)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            Text(description).fontSize(15).opacity(0.75).frame(maxWidth: .infinity, alignment: .topLeading)
          }
          Image(systemName: "chevron.right")
            .fontSize(14, .semibold)
            .opacity(0.35)
            .foregroundColor(.primary)
        }
      }
      .multilineTextAlignment(.leading)
      .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 20))
      .frame(maxWidth: .infinity)
      .themedListRowLikeBG(pressed: pressed)
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      .contentShape(Rectangle())
    }
  }
}
