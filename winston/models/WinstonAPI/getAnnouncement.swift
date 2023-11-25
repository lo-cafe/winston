//
//  getAnnouncement.swift
//  winston
//
//  Created by daniel on 25/11/23.
//

import Foundation
import Alamofire

extension WinstonAPI {
  func getAnnouncement() async -> Announcement? {
      let response = await AF.request(
        "\(WinstonAPI.baseURL)/api/v1/announcement",
        method: .get
      )
        .serializingDecodable(Announcement.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        print(error)
        print(response.response)
        return nil
      }
  }
}

struct Announcement: Codable{
  var name: String?
  var description: String?
  var buttonLabel: String?
  var timestamp: Int?
}
