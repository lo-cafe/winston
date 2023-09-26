//
//  themeStore.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import Foundation
import Alamofire
class ThemeStoreAPI: ObservableObject {
  static let baseURL = "http://localhost:3000"
  static let bearerToken = "2cYk@dXT!ZjXagF_-h6x"
  
  func getRequestHeaders(includeAuth: Bool = true) -> HTTPHeaders? {
    var headers: HTTPHeaders = []
    headers["Authorization"] = "Bearer \(ThemeStoreAPI.bearerToken)"
    
    return headers
  }
}

extension ThemeStoreAPI {
  func fetchAllThemes() async -> [ThemeData]? {
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(ThemeStoreAPI.baseURL)/themes",
        method: .get,
        headers: headers
      )
        .serializingDecodable([ThemeData].self).response
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
  
  
  
  struct FetchInboxPayload: Codable {
    var mark = "true"
    var count = 0
    var after = ""
    var before = ""
    var limit = 25
    var show = "all"
    var sr_detail = 1
  }
}

struct ThemeData: Codable, Hashable {
  var filename: String?
  var file_id: String?
  var theme_name: String?
  var theme_author: String?
  var theme_description: String?
  var approval_state: String?
  var attachment_url: String?
  var color: ThemeColor?
  var icon: String?
}

//{
//        "file_name": "1695662953750-0867145e-a195-4bbc-858c-26d9d7dd43ce.zip",
//        "file_id": "1695662953750-0867145e-a195-4bbc-858c-26d9d7dd43ce",
//        "theme_name": "Nalryf",
//        "theme_author": "@bberries",
//        "theme_description": "",
//        "approval_state": "accepted",
//        "attachment_url": "https://cdn.discordapp.com/attachments/1155789985006493707/1155919023981215844/1695662953750-0867145e-a195-4bbc-858c-26d9d7dd43ce.zip",
//        "color": {
//            "hex": "c48fff",
//            "alpha": 1
//        }
//  },
