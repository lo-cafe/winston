//
//  getFlairs.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func getFlairs(_ subName: String) async -> [Flair]? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/r/\(subName)/api/link_flair_v2",
        method: .get,
        headers: headers
      )
        .serializingDecodable(FlairsResponse.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        return nil
      }
    }
    return nil
  }
  
  typealias FlairsResponse = [Flair]
}

struct Flair: GenericRedditEntityDataType, Identifiable {
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
