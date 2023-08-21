//
//  duplicateMulti.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func duplicateMulti(from: String, to: String) async -> Bool? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders(), let myName = me?.data?.name {
      let params = ["from":"/user/\(myName)/m/\(from)","to":"/user/\(myName)/m/\(to)"]
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/multi/copy",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
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
