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
      switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/\(path)", method: .delete) {
      case .success:
        return true
      case .failure:
        //        print(error)
        return nil
      }
  }
}
