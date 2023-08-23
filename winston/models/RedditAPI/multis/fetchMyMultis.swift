//
//  fetchMyMultis.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Defaults
import Alamofire
import SwiftUI

extension RedditAPI {
  func fetchMyMultis() async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = ["expand_srs":true]
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi/mine",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      ).serializingDecodable([MultiContainerResponse].self).response
      switch response.result {
      case .success(let data):
        let toStore = data.compactMap { x in
          var newData = x
          newData.data?.subreddits = x.data?.subreddits?.compactMap({ multiSub in
            var newMultiSub = multiSub
            newMultiSub.data?.description = ""
            newMultiSub.data?.description_html = ""
            newMultiSub.data?.public_description = ""
            newMultiSub.data?.public_description_html = ""
            newMultiSub.data?.submit_text_html = ""
            newMultiSub.data?.submit_text = ""
            return newMultiSub
          })
          return newData.data
        }
        
        await MainActor.run { [toStore] in
          withAnimation {
            Defaults[.multis] = toStore
          }
        }
        return nil
      case .failure(let error):
//        print("kmkm")
                print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct MultiContainerResponse: Codable {
      let kind: String?
      var data: MultiData?
  }
}
