//
//  getEligibility.swift
//  winston
//
//  Created by Daniel Inama on 27/09/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func getEligibilits(id: String) async -> Bool? {
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(ThemeStoreAPI.baseURL)/eligibility/" + id,
        method: .get,
        headers: headers
      )
        .serializingDecodable(Bool.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        Oops.shared.sendError(error)
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}

func generateShortUniqueID() -> String {
    let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let timestamp = Int(Date().timeIntervalSince1970)
    
    var randomID = ""
    
    for _ in 0..<5 {
        let randomIndex = Int.random(in: 0..<allowedCharacters.count)
        let character = allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: randomIndex)]
        randomID.append(character)
    }
    
    return "\(timestamp)\(randomID)"
}
