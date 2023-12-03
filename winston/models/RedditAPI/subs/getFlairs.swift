//
//  getFlairs.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import Foundation
import Alamofire
import Defaults
import UIKit

extension RedditAPI {
  func getFlairs(_ subName: String) async -> [Flair]? {
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/r/\(subName)/api/link_flair_v2", method: .get, decodable: FlairsResponse.self)  {
    case .success(let data):
      return data
    case .failure(let error):
      return nil
    }
  }
  
  typealias FlairsResponse = [Flair]
}

struct Flair: GenericRedditEntityDataType, Identifiable, Defaults.Serializable {
      let type: String?
      let text_editable: Bool?
      let allowable_content: String?
      let text: String?
      let max_emojis: Int?
      let text_color: String?
      let mod_only: Bool?
      let css_class: String?
      let background_color: String?
      let id: String
}

struct FlairData: Identifiable, Codable, Defaults.Serializable, Equatable, Hashable {
  static func == (lhs: FlairData, rhs: FlairData) -> Bool {
    return lhs.text == rhs.text && lhs.text_color == rhs.text_color && lhs.background_color == rhs.background_color
  }
  
  let id: String
  let text: String
  let text_color: String
  let background_color: String
  let occurences: Int
  
  init(text: String, text_color: String, background_color: String, occurences: Int = 0) {
    self.id = text
    self.text = text
    self.text_color = text_color
    self.background_color = background_color
    self.occurences = occurences + 1
  }
  
  func getFormattedText() -> String {
    return self.text.replacingOccurrences(of: "&amp;", with: "&")
  }
}
