//
//  MasterButton.swift
//  winston
//
//  Created by Igor Marcossi on 29/06/23.
//

import SwiftUI

let BTN_SHRINK_ANIMATION = Animation.spring(response: 0.35)

enum MasterButtonMode {
  case soft
  case normal
  case subtle
}

enum ColorHoverEffect {
  case none
  case normal
  case animated
}

enum ProportionalTypes {
  case no
  case circle
  case yes
}

struct MasterButton: View {
  var softDisabled = false
  var icon: String? = nil
  var img: String? = nil
  var label: String? = nil
  var mode: MasterButtonMode = .normal
  var color: Color = .blue
  var colorHoverEffect: ColorHoverEffect = .none
  var textColor: Color = .white
  var textSize: CGFloat = 16
  var textWeight: Font.Weight = .semibold
  var textDesign: Font.Design = .rounded
  var shrinkHoverEffect: Bool = false
  var padding: CGFloat = 10
  var height: CGFloat = 36
  var fullWidth: Bool = false
  var align: Alignment = .center
  var fullHeight: Bool = false
  var cornerRadius: CGFloat = 10
  var shrinkRatio: CGFloat = 0.1
  var confirmLabel: String? = nil
  var proportional: ProportionalTypes = .no
  var growAnchor: Alignment = .center
  var disabled = false
  var hoverWorkaround = false
  let action: () -> Void
    
  var body: some View {
    let btnCornerRadius = proportional == .circle ? height / 2 : cornerRadius
    let finalColor = color.opacity(mode == .normal ? 1 : mode == .subtle ? 0 : 0.2 )
    let proportionalSize = proportional != .no ? height : nil
    HStack {
      if let img = img {
        Image(img)
          .resizable()
          .scaledToFit()
          .frame(height: textSize)
      }
      if let icon = icon {
        Image(systemName: icon).contentTransition(.symbolEffect)
      }
      Group {
        if let label = label {
          Text(label).fixedSize(horizontal: true, vertical: false)
        }
      }
      .transition(.scaleAndBlur)
    }
    .fontSize(textSize, textWeight, design: textDesign)
    //            .padding(.vertical, padding)
    .padding(.horizontal, 10 * 1.5)
    .foregroundColor(textColor)
    .frame(maxWidth: fullWidth ? .infinity : nil, maxHeight: fullHeight ? .infinity : height, alignment: align)
    .frame(width: proportionalSize, height: fullHeight ? nil : height)
    .background(RR(btnCornerRadius, finalColor))
    .mask(RR(btnCornerRadius, .black))
    .contentShape(RoundedRectangle(cornerRadius: btnCornerRadius, style: .continuous))
    .highPriorityGesture(softDisabled ? nil : TapGesture().onEnded { action() })
    .disabled(disabled)
    .saturation(disabled ? 0 : 1)
    .opacity(disabled ? 0.65 : 1)
    .frame(maxWidth: fullWidth ? .infinity : nil, alignment: growAnchor)
  }
}

