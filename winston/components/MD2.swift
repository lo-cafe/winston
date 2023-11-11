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

struct MD2: UIViewRepresentable {
  var attributedString: AttributedString
  var fontSize: CGFloat
  
  
  init(_ content: MDType,
       fontSize: CGFloat = 15
  ) {
    self.fontSize = fontSize
    switch content {
    case .attr(let attr):
      self.attributedString = attr
    case .str(let str):
      self.attributedString = stringToAttr(str, fontSize: fontSize)
    case .json(let json):
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: json.data(using: .utf8)!)) ?? AttributedString()
      self.attributedString = jsonData
    }
  }
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.attributedText = NSAttributedString(attributedString)
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
    uiView.attributedText = NSAttributedString(attributedString)
  }
  
  // Coordinator to handle the delegate method
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // Coordinator class to handle delegate methods
  class Coordinator: NSObject, UITextViewDelegate {
    var parent: MD2
    
    init(_ parent: MD2) {
      self.parent = parent
    }
    
    // Implement the UITextViewDelegate method to handle URL interaction
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
      // Handle URL interaction here
      // You can open the URL, display it differently, or perform any other action as needed
      let vcConfig = SFSafariViewController.Configuration()
//      vcConfig.entersReaderIfAvailable = Defaults[.useReaderMode]
      var vc: UIViewController?
      
      switch interaction {
      case .invokeDefaultAction:
        if isImageUrl(URL.absoluteString)  {
          let imageView = ImageView(url: URL) // Create a custom ImageView
          let hostingController = UIHostingController(rootView: imageView)
          hostingController.overrideUserInterfaceStyle = .dark
          vc = hostingController
        } else {
          vc = SFSafariViewController(url: URL, configuration: vcConfig)
        }
      case .presentActions:
        break
      case .preview:
        break
      @unknown default:
        break
      }
      
      if vc != nil && !Defaults[.openLinksInSafari]{
        UIApplication.shared.windows.first?.rootViewController?.present(vc!, animated: true)
        return false
      } else {
        return true
      }
    }
  }
}

struct ImageView: View {
  var url: URL
  @Namespace var presentationNamespace
  
  var body: some View {
    LightBoxImage(post: nil, i: 0, imagesArr: [MediaExtracted(url: url, size: CGSize(width: 100, height: 100))], doLiveText: true)
  }
}
