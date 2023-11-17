//
//  getPreviewImages.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func getPreviewImages(id: String) async -> PreviewImages? {
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(ThemeStoreAPI.baseURL)/themes/previews/" + id,
        method: .get,
        headers: headers
      )
        .serializingDecodable(PreviewImages.self).response
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

struct PreviewImages: Codable{
  var previews: [String]
}
