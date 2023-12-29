//
//  MD2.swift
//  winston
//
//  Created by Daniel Inama on 05/09/23.
//

import SwiftUI
import UIKit
import Markdown
import SafariServices
import Defaults
import NukeUI

struct MD2: UIViewRepresentable {
  var attributedString: NSAttributedString
  var fontSize: CGFloat
  var onTap: (() -> ())? = nil
  
  init(_ content: MDType, fontSize: CGFloat = 15, onTap: (() -> ())? = nil) {
    self.onTap = onTap
    self.fontSize = fontSize
    switch content {
    case .nsAttr(let nsAttr):
      self.attributedString = nsAttr
    case .attr(let attr):
      self.attributedString = NSAttributedString(attr)
    case .str(let str):
      self.attributedString = stringToNSAttr(str, fontSize: fontSize)
    case .json(let json):
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: json.data(using: .utf8)!)) ?? AttributedString()
      self.attributedString = NSAttributedString(jsonData)
    }
  }
  
  func makeUIView(context: Context) -> UITextView {
    //    let textView = UnselectableTappableTextView()
    let textView = UITextView()
    textView.attributedText = attributedString
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = true
    textView.backgroundColor = .clear
    textView.textContainer.lineFragmentPadding = 0
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // Adjust horizontal
    textView.textContainerInset = .zero
    textView.delegate = context.coordinator // Set the delegate
    
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    context.coordinator.parent = self
    uiView.attributedText = attributedString
  }
  
  // Coordinator to handle the delegate method
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // Coordinator class to handle delegate methods
  class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
    var parent: MD2
    
    init(_ parent: MD2) {
      self.parent = parent
    }
    
//    @objc func tap(gesture: UITapGestureRecognizer) {
//      parent.onTap?()
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return false
    }
    
    // Implement the UITextViewDelegate method to handle URL interaction
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
      switch interaction {
      case .invokeDefaultAction:
        if Defaults[.BehaviorDefSettings].openLinksInSafari || url.scheme?.lowercased().contains(/http(s)?/)==false {
          return true
        }
        if isImageUrl(url.absoluteString)  {
          let imageView = ImageView(url: url) // Create a custom ImageView
          let hostingController = UIHostingController(rootView: imageView)
          hostingController.overrideUserInterfaceStyle = .dark
          UIApplication.shared.firstKeyWindow?.rootViewController?.present(hostingController, animated: true)
        } else {
          Nav.openURL(url)
        }
        return false
        //      case .presentActions:
        //        break
        //      case .preview:
        //        break
      default:
        return false
      }
    }
  }
}

struct ImageView: View {
  var url: URL
  @Namespace var presentationNamespace
  
  var body: some View {
    LightBoxImage(i: 0, imagesArr: [ImgExtracted(url: url, size: CGSize(width: 100, height: 100), request: ImageRequest(url: url))], doLiveText: true)
  }
}

//class UnselectableTappableTextView: UITextView {
//
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        guard super.point(inside: point, with: event) else { return false }
//        guard let pos = closestPosition(to: point) else { return false }
//        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }
//        let startIndex = offset(from: beginningOfDocument, to: range.start)
//        guard startIndex < self.attributedText.length - 1 else { return false } // to handle the case where the text ends with a link and the user taps in the space after the link.
//        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
//    }
//
//    // 1. Prevent the user from selecting the link text
//    // 2. Disable magnifing glass
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let gestureDelegate = gestureRecognizer.delegate {
//            if gestureDelegate.description.localizedCaseInsensitiveContains("UITextSelectionInteraction") {
//                return false
//            }
//        }
//        return true
//    }
//
//}
