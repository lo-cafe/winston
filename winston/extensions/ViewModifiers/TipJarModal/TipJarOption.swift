//
//  TipJarOption.swift
//  winston
//
//  Created by Igor Marcossi on 21/03/24.
//

import SwiftUI

struct TipJarOption: View {
  var title: String
//  var comets: Int
  var description: String
  var price: String
  var selected: Bool
  var onTap: () -> ()
  @State private var pressing = false
  var body: some View {
    VStack(alignment: .leading, spacing: 1) {
      HStack(alignment: .center) {
        Text(title).fontSize(16, .medium)
        Spacer()
        
        Text(price).fontSize(16, .semibold)
      }
      
      Text(description).fontSize(15)
        .opacity(0.75)
    }
    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
//    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke((selected ? Color.accentColor : Color.primary).opacity(selected ? 1 : 0.15), lineWidth: 1).padding(.all, 1))
    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke((selected ? Color.accentColor : Color.primary).opacity(selected ? 1 : 0.25), lineWidth: 1).padding(.all, 1).blendMode(.overlay))
    .foregroundStyle(selected ? Color.accentColor : Color.primary)
    .contentShape(Rectangle())
    .compositingGroup()
    .opacity(pressing ? 0.75 : 1)
    .onTapGesture {
      onTap()
    }
    .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 20, perform: {}) { pressing in
      self.pressing = pressing
    }
  }
}
