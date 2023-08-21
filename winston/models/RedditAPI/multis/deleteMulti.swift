//
//  deleteMulti.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func deleteMulti(_ path: String) async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi/\(path)",
        method: .delete,
        headers: headers
      ).serializingString()
      let result = await dataTask.result
      switch result {
      case .success:
        return true
      case .failure:
        //        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
