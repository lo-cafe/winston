////
////  DownAttributedString.swift
////  winston
////
////  Created by Igor Marcossi on 02/07/23.
////
//
//import Foundation
//import SwiftUI
//import Down
//
//struct ParagraphMe: ParagraphStyleCollection {
//  var heading1: NSParagraphStyle
//  
//  var heading2: NSParagraphStyle
//  
//  var heading3: NSParagraphStyle
//  
//  var heading4: NSParagraphStyle
//  
//  var heading5: NSParagraphStyle
//  
//  var heading6: NSParagraphStyle
//  
//  var body: NSParagraphStyle
//  
//  var code: NSParagraphStyle
//  
//  public init() {
//      let headingStyle = NSMutableParagraphStyle()
//      headingStyle.paragraphSpacingBefore = 0
//      headingStyle.paragraphSpacing = 8
//
//      let bodyStyle = NSMutableParagraphStyle()
//      bodyStyle.paragraphSpacingBefore = 0
//      bodyStyle.paragraphSpacing = 8
//      bodyStyle.lineSpacing = 0
//
//      let codeStyle = NSMutableParagraphStyle()
//      codeStyle.paragraphSpacingBefore = 0
//      codeStyle.paragraphSpacing = 8
//
//      heading1 = headingStyle
//      heading2 = headingStyle
//      heading3 = headingStyle
//      heading4 = headingStyle
//      heading5 = headingStyle
//      heading6 = headingStyle
//      body = bodyStyle
//      code = codeStyle
//  }
//}
//
//let configuration = DownStylerConfiguration()
//
//struct MarkdownRepresentable: UIViewRepresentable {
//  let textView = UITextView()
//  private let text: String
//  
//  let fonts = StaticFontCollection(heading1: UIFont.preferredFont(forTextStyle: .largeTitle), heading2:     UIFont.preferredFont(forTextStyle: .title1), heading3: UIFont.preferredFont(forTextStyle: .title2), heading4: UIFont.preferredFont(forTextStyle: .title3), heading5: UIFont.preferredFont(forTextStyle: .headline), heading6: UIFont.preferredFont(forTextStyle: .subheadline), body: UIFont.preferredFont(forTextStyle: .body).withSize(15), code: UIFont.preferredFont(forTextStyle: .body).withSize(15), listItemPrefix: UIFont.preferredFont(forTextStyle: .body).withSize(15))
//  let colors = configuration.colors
//  let paragraphStyles = ParagraphMe()
//  let quoteStripeOptions = configuration.quoteStripeOptions
//  let thematicBreakOptions = configuration.thematicBreakOptions
//  let codeBlockOptions = configuration.codeBlockOptions
//  let itemParagraphStyler = ListItemOptions()
//  @Environment(\.colorScheme) var colorScheme
//  var attributedText: NSAttributedString?
//  
//  init(text: String) {
//    self.text = text
//    textView.textAlignment = .left
//    textView.backgroundColor = .clear
////    textView.lineBreakMode = .byWordWrapping
////    textView.numberOfLines = 0
//    let down = Down(markdownString: text)
//    attributedText = try? down.toAttributedString(.sourcePos, styler: DownStyler(configuration: .init(fonts: self.fonts, colors: self.colors, paragraphStyles: self.paragraphStyles, listItemOptions: self.itemParagraphStyler, quoteStripeOptions: quoteStripeOptions, thematicBreakOptions: thematicBreakOptions, codeBlockOptions: self.codeBlockOptions)))
////    textView.preferredMaxLayoutWidth =  textView.bounds.width
//  }
//  
//  func makeUIView(context: Context) -> UITextView {
//    textView.isEditable = false
//    textView.isScrollEnabled = false
//    textView.backgroundColor = .clear
//    textView.textContainer.lineFragmentPadding = 0
//    textView.textContainerInset = .zero
//      return textView
//  }
//  
//  func updateUIView(_ uiView: UITextView, context: Context) {
//    DispatchQueue.main.async {
////      uiView.preferredMaxLayoutWidth = uiView.bounds.width
//      textView.attributedText = attributedText
//      uiView.textColor = colorScheme == .dark ? UIColor.white : UIColor.black
//    }
//  }
//}
////
//struct DownAttributedString: View {
//  var attributedText: AttributedString
////  var fontSize: CGFloat = 15
//  
//  let fonts = StaticFontCollection(heading1: UIFont.preferredFont(forTextStyle: .largeTitle), heading2:     UIFont.preferredFont(forTextStyle: .title1), heading3: UIFont.preferredFont(forTextStyle: .title2), heading4: UIFont.preferredFont(forTextStyle: .title3), heading5: UIFont.preferredFont(forTextStyle: .headline), heading6: UIFont.preferredFont(forTextStyle: .subheadline), body: UIFont.preferredFont(forTextStyle: .body).withSize(15), code: UIFont.preferredFont(forTextStyle: .body).withSize(15), listItemPrefix: UIFont.preferredFont(forTextStyle: .body).withSize(15))
//  let colors = configuration.colors
//  let paragraphStyles = ParagraphMe()
//  let quoteStripeOptions = configuration.quoteStripeOptions
//  let thematicBreakOptions = configuration.thematicBreakOptions
//  let codeBlockOptions = configuration.codeBlockOptions
//  let itemParagraphStyler = ListItemOptions()
//  
//  init(text: String) {
//    let down = Down(markdownString: text)
//    if let newText = try? down.toAttributedString(.sourcePos, styler: DownStyler(configuration: .init(fonts: self.fonts, colors: self.colors, paragraphStyles: self.paragraphStyles, listItemOptions: self.itemParagraphStyler, quoteStripeOptions: quoteStripeOptions, thematicBreakOptions: thematicBreakOptions, codeBlockOptions: self.codeBlockOptions))) {
//      var newAttributedText = AttributedString(newText)
//      newAttributedText.foregroundColor = .primary
//      attributedText = newAttributedText
//    } else {
//      attributedText = AttributedString("Error")
//    }
//  }
//  
//  var body: some View {
//    Text(attributedText)
//      .fixedSize(horizontal: false, vertical: true)
//    //    VStack(alignment: .leading) {
//    //      if isLoading {
//    //          ProgressView()
//    //            .frame(width: .infinity, alignment: .center)
//    //      } else {
////      if maxWidth != 0 {
////      MarkdownRepresentable(text: text)
////          .frame(width: maxWidth, height: height)
////        .frame(maxWidth: .infinity)
////          .clipped()
////          .environmentObject(markdownObject)
////          .opacity(height == 0 ? 0 : 1)
////      }
////    .frame(maxWidth: .infinity, maxHeight: height)
////    .background(
////      GeometryReader { geo in
////        Color.clear
////          .onAppear {
////            maxWidth = geo.size.width
////          }
////          .onChange(of: geo.size.width) { newValue in
////            maxWidth = newValue
////          }
////      }
////    )
//    //            .onReceive(markdownObject.$isLoading, perform: { bool in
//    //              isLoading = bool
//    //            })
//    //      }
//    //    }
//  }
//}
