//
//  fetchThemeStatus.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func fetchThemeStatus(id: String) async -> ThemeStatus? {
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(ThemeStoreAPI.baseURL)/themes/status/" + id,
        method: .get,
        headers: headers
      )
        .serializingDecodable(ThemeStatus.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}

struct ThemeStatus: Codable {
  var status: String?
}
