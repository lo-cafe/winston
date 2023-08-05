//
//  SelectableText.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import SwiftUI
import UIKit

struct TextViewWrapper: UIViewRepresentable {
  var attributedText: NSAttributedString
  var maxLayoutWidth: CGFloat
  
  func makeUIView(context: Context) -> TextView {
    let uiView = TextView()
    
    uiView.backgroundColor = .clear
    uiView.textContainerInset = .init(top: 3, left: 0, bottom: 0, right: 0)
    uiView.isEditable = false
    uiView.font = UIFont.systemFont(ofSize: 15)
    uiView.textColor = UIColor(Color.primary)
    uiView.isSelectable = true
    uiView.isScrollEnabled = false
    uiView.textContainer.lineFragmentPadding = 0
    
    return uiView
  }
  
  func updateUIView(_ uiView: TextView, context: Context) {
    uiView.attributedText = attributedText
    uiView.maxLayoutWidth = maxLayoutWidth
    uiView.font = UIFont.systemFont(ofSize: 15)
    uiView.textColor = UIColor(Color.primary)
  }
}

final class TextView: UITextView {
  var maxLayoutWidth: CGFloat = 0 {
    didSet {
      guard maxLayoutWidth != oldValue else { return }
      invalidateIntrinsicContentSize()
    }
  }
  
  override var intrinsicContentSize: CGSize {
    guard maxLayoutWidth > 0 else {
      return super.intrinsicContentSize
    }
    
    return sizeThatFits(
      CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
    )
  }
}
