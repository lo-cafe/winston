//
//  stringToAttr.swift
//  winston
//
//  Created by Igor Marcossi on 03/09/23.
//

import SwiftUI
import Markdown

func stringReplacements(_ str: String) -> String {
    let formatted = str.replacing("&gt;", with: ">").replacing(/&amp;#x200B;|&amp;nbsp;/, with: "")
    
    return formatted
}


func stringToAttr(_ str: String, fontSize: CGFloat = 15) -> AttributedString {
  let formatted = stringReplacements(str)
  
  let document = Document(parsing: formatted)
  var markdownosaur = Markdownosaur(baseFontSize: fontSize)
  let attributedString = markdownosaur.attributedString(from: document)
  return AttributedString(attributedString)
}


func stringToNSAttr(_ str: String, fontSize: CGFloat = 15) -> NSAttributedString {
  let formatted = stringReplacements(str)
  
  let document = Document(parsing: formatted)
  var markdownosaur = Markdownosaur(baseFontSize: fontSize)
  let attributedString = markdownosaur.attributedString(from: document)
  return attributedString
}


func stringToMutableNSAttr(_ str: String, fontSize: CGFloat = 15) -> NSAttributedString {
  let formatted = stringReplacements(str)
  
  let document = Document(parsing: formatted)
  var markdownosaur = Markdownosaur(baseFontSize: fontSize)
  let attributedString = markdownosaur.attributedString(from: document)
  return attributedString
}
