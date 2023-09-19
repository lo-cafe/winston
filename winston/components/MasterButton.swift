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
  
//  @State var initialSize = CGSize.zero
  @State var confirming = false
  @GestureState var pressing = false
  
  var body: some View {
    let btnCornerRadius = proportional == .circle ? height / 2 : cornerRadius
    let finalColor = color.opacity(mode == .normal ? 1 : mode == .subtle ? pressing ? 0.1 : 0 : 0.2 )
    let proportionalSize = proportional != .no ? height : nil
    //    Button {
    //      if confirmLabel != nil {
    //        if confirming {
    //          action()
    //        } else {
    //          withAnimation(BTN_SHRINK_ANIMATION) {
    //            confirming = true
    //          }
    //        }
    //      } else {
    //        action()
    //      }
    //    } label: {
    HStack {
      if let img = img {
        Image(img)
          .resizable()
          .scaledToFit()
          .frame(height: textSize)
      }
      if let icon = icon {
        Image(systemName: icon)
          .transition(.scaleAndBlur)
          .id(icon)
      }
      Group {
        if let label = label {
          Text(confirming ? confirmLabel ?? label : label)
            .fixedSize(horizontal: true, vertical: false)
            .id(confirming ? confirmLabel : label)
        } else if let confirmLabel = confirmLabel, confirming {
          Text(confirmLabel)
            .font(Font(UIFont.systemFont(ofSize: 11, weight: .medium)))
            .id(confirmLabel)
        }
      }
      .transition(.scaleAndBlur)
    }
    .fontSize(textSize, textWeight, design: textDesign)
    //            .padding(.vertical, padding)
    .padding(.horizontal, 10 * 1.5)
    .foregroundColor(textColor)
    .frame(maxWidth: fullWidth ? .infinity : nil, maxHeight: fullHeight ? .infinity : height, alignment: align)
    .frame(width: confirming ? nil : proportionalSize, height: fullHeight ? nil : height)
    .background(
      RR(btnCornerRadius, finalColor)
        .brightness(colorHoverEffect != .none ? pressing ? -0.1 : 0 : 0)
    )
    .mask(
      RR(btnCornerRadius, .white)
    )
    .scaleEffect(1 + (shrinkHoverEffect ? pressing ? -shrinkRatio : 0 : 0) )
    
    .if(hoverWorkaround) { v in
      v.contentShape(RoundedRectangle(cornerRadius: btnCornerRadius, style: .continuous))
    }
    .animation(shrinkHoverEffect || colorHoverEffect == .animated ? BTN_SHRINK_ANIMATION : nil, value: pressing)
    .if(!hoverWorkaround) { v in
      v.contentShape(RoundedRectangle(cornerRadius: btnCornerRadius, style: .continuous))
    }
    //    }
    .highPriorityGesture(
      TapGesture()
        .onEnded {
          if confirmLabel != nil {
            if confirming {
              action()
            } else {
              withAnimation(BTN_SHRINK_ANIMATION) {
                confirming = true
              }
            }
          } else {
            action()
          }
        }
    )
//    .simultaneousGesture(
//      colorHoverEffect == .none
//      ? nil
//      : LongPressGesture(minimumDuration: 1, maximumDistance: 1)
//        .updating($pressing, body: { newPressing, pressing, transaction in
//          pressing = newPressing
//        })
//    )
    .disabled(disabled)
    .saturation(disabled ? 0 : 1)
    .opacity(disabled ? 0.65 : 1)
    .fixedSize(horizontal: confirming, vertical: confirming)
    //    .getInitialSize($initialSize)
//    .frame(maxWidth: fullWidth ? .infinity : confirming ? initialSize.width : nil, alignment: growAnchor)
    .frame(maxWidth: fullWidth ? .infinity : nil, alignment: growAnchor)
//    .buttonStyle(NoBtnStyle())
    .onChange(of: confirming) { newValue in
      if newValue {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          withAnimation(BTN_SHRINK_ANIMATION) {
            confirming = false
          }
        }
      }
    }
  }
}

struct NoBtnStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}
