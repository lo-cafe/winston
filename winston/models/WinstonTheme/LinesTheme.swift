//
//  LinesTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

enum LineTypeTheme: Codable, Hashable, CaseIterable {
  case line, fancy, no
}

struct LineTheme: Codable, Hashable {
  var style: LineTypeTheme?
  var thickness: CGFloat
  var color: ColorSchemes<ThemeColor>
}
