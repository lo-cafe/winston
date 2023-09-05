//
//  MD2.swift
//  winston
//
//  Created by Daniel Inama on 05/09/23.
//

import SwiftUI
import UIKit
import Markdown
import BetterSafariView
import SafariServices

struct MD2: UIViewRepresentable {
  var attributedString: AttributedString
  var str: String?
  
  init(_ content: MDType, fontSize: CGFloat = 15) {
    switch content {
    case .attr(let attr):
      self.attributedString = attr
    case .str(let str):
      self.str = str
      self.attributedString = stringToAttr(str, fontSize: fontSize)
    case .json(let json):
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: json.data(using: .utf8)!)) ?? AttributedString()
      self.attributedString = jsonData
    }
  }
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.sizeToFit()
    textView.attributedText = NSAttributedString(attributedString)
    textView.delegate = context.coordinator // Set the delegate
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.attributedText = NSAttributedString(attributedString)
  }
  
  // Coordinator to handle the delegate method
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // Coordinator class to handle delegate methods
  class Coordinator: NSObject, UITextViewDelegate {
    var parent: MD2
    @EnvironmentObject private var routerProxy: RouterProxy
    
    
    init(_ parent: MD2) {
      self.parent = parent
    }
    
    // Implement the UITextViewDelegate method to handle URL interaction
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
      // Handle URL interaction here
      // You can open the URL, display it differently, or perform any other action as needed
//      print("Interacted with URL: \(URL.absoluteString)")
      var vc: SFSafariViewController?
      
      switch interaction {
      case .invokeDefaultAction:
        vc = SFSafariViewController(url: URL)
      case .presentActions:
        break
      case .preview:
        break
      @unknown default:
        break
      }
      
      // Return false to allow the default action to be performed (e.g., open the URL)
      if let vc {
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
        return false
      } else {
        return true
      }
    }
  }
}

