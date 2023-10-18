//
//  ViewWrapper.swift
//  winston
//
//  Created by Igor Marcossi on 08/10/23.
//

import Foundation
import SwiftUI
import UIKit
import SubviewAttachingTextView

struct PrependTag: Hashable, Equatable {
  let label: String
  let bgColor: Color
}

func buildTitleAttr(title: String, tags: [PrependTag], fontSize: Double, fontWeight: UIFont.Weight, color: Color, size: CGSize) -> NSAttributedString {
  let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
  var appends: [SubviewTextAttachment] = []
  appends = createTagLabels(tags).map { SubviewTextAttachment(view: $0) }
  let spaces = appends.reduce(into: "") { partialResult, _ in
    partialResult = partialResult + " "
  }
  let textStr = NSMutableAttributedString(string: "\(title)\(spaces)", attributes: [.font: font, .foregroundColor: UIColor(color)])
  Array(appends.enumerated()).forEach { i, attachment in
    attachment.bounds = CGRectIntegral(CGRect(x: 0, y: font.descender - attachment.bounds.size.height / 2 + (font.descender + font.capHeight) + 2, width: attachment.bounds.size.width, height: attachment.bounds.size.height))
    textStr.insertAttachment(attachment, at: title.count + 1 + (i * 2))
  }
  if appends.count > 0 {
    textStr.append(.init(string: " "))
  }
  return textStr
  
  func createTagLabels(_ tags: [PrependTag]) -> [UIView] {
    return tags.map { tag in
      let label = UILabel()
      label.text = tag.label
      label.font = UIFont.systemFont(ofSize: ((fontSize - 2) * 100) / 120, weight: .medium)
      label.backgroundColor = UIColor.clear
      label.textAlignment = .center
      label.translatesAutoresizingMaskIntoConstraints = false
      let view = UIView()
      
      view.addSubview(label)
      view.backgroundColor = UIColor(tag.bgColor)
      view.layer.cornerRadius = 5
      view.layer.cornerCurve = .continuous
      view.layer.masksToBounds = true
      NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 1),
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1),
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
      ])
      view.layer.opacity = 0.5
      return view
    }
  }
}

func buildTitleWithTags(title: String, tags: [PrependTag], fontSize: Double, fontWeight: UIFont.Weight, color: Color, size: CGSize) -> UIView {
  let attr = buildTitleAttr(title: title, tags: tags, fontSize: fontSize, fontWeight: fontWeight, color: color, size: size)
  let lm = NSLayoutManager()
  let ts = NSTextStorage()
  ts.addLayoutManager(lm)
  let tc = NSTextContainer(size: size)
  lm.addTextContainer(tc)
  let text = SubviewAttachingTextViewNoPad(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), textContainer: tc)
  text.attributedText = attr
  text.backgroundColor = .clear
//  text.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
  text.isEditable = false
  text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  text.isScrollEnabled = false
  text.translatesAutoresizingMaskIntoConstraints = false
  text.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
  return text
}

struct Prepend: UIViewRepresentable {
  
  var title: String
  var fontSize: CGFloat
  var fontWeight: UIFont.Weight
  var color: Color
  var tags: [PrependTag]
  var size: CGSize
  
  func makeUIView(context: Context) -> UIView {
    let view = buildTitleWithTags(title: title, tags: tags, fontSize: fontSize, fontWeight: fontWeight, color: color, size: size)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) { }
}

public extension NSTextAttachment {
  
  convenience init(image: UIImage, size: CGSize? = nil) {
    self.init(data: nil, ofType: nil)
    
    self.image = image
    if let size = size {
      self.bounds = CGRect(origin: .zero, size: size)
    }
  }
  
}

public extension NSAttributedString {
  
  func insertingAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
    let copy = self.mutableCopy() as! NSMutableAttributedString
    copy.insertAttachment(attachment, at: index, with: paragraphStyle)
    
    return copy.copy() as! NSAttributedString
  }
  
  func addingAttributes(_ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
    let copy = self.mutableCopy() as! NSMutableAttributedString
    copy.addAttributes(attributes)
    
    return copy.copy() as! NSAttributedString
  }
  
}

public extension NSMutableAttributedString {
  
  func insertAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
    let plainAttachmentString = NSAttributedString(attachment: attachment)
    
    if let paragraphStyle = paragraphStyle {
      let attachmentString = plainAttachmentString
        .addingAttributes([ .paragraphStyle : paragraphStyle ])
      let separatorString = NSAttributedString(string: .paragraphSeparator)
      
      // Surround the attachment string with paragraph separators, so that the paragraph style is only applied to it
      let insertion = NSMutableAttributedString()
      insertion.append(separatorString)
      insertion.append(attachmentString)
      insertion.append(separatorString)
      
      self.insert(insertion, at: index)
    } else {
      self.insert(plainAttachmentString, at: index)
    }
  }
  
  //    func addAttributes(_ attributes: [NSAttributedString.Key : Any]) {
  //        self.addAttributes(attributes, range: NSRange(location: 0, length: self.length))
  //    }
  
}

public extension String {
  
  static let paragraphSeparator = "\u{2029}"
  
}

open class SubviewAttachingTextViewNoPad: UITextView {
  
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    self.commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  private let attachmentBehavior = SubviewAttachingTextViewBehavior()
  
  private func commonInit() {
    // Connect the attachment behavior
    self.attachmentBehavior.textView = self
    self.layoutManager.delegate = self.attachmentBehavior
    self.textStorage.delegate = self.attachmentBehavior
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    setup()
  }
  
  open override var textContainerInset: UIEdgeInsets {
    didSet {
      // Text container insets are used to convert coordinates between the text container and text view, so a change to these insets must trigger a layout update
      self.attachmentBehavior.layoutAttachedSubviews()
    }
  }
  
  func setup() {
    textContainerInset = UIEdgeInsets.zero
    textContainer.lineFragmentPadding = 0
    textContainer.maximumNumberOfLines = 0
  }
  
}
