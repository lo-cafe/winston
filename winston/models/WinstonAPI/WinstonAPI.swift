//
//  winstonAPI.swift
//  winston
//
//  Created by daniel on 25/11/23.
//

import Foundation
import Alamofire

class WinstonAPI: ObservableObject {
    static let baseURL = "https://preview.webhook.metisbot.xyz"
//  static let baseURL = "http://localhost:3000"
//  static let bearerToken = "2cYk@dXT!ZjXagF_-h6x"
  
  
  @Published var announcement: Announcement? = nil
  
  func getRequestHeaders(includeAuth: Bool = true) -> HTTPHeaders? {
    var headers: HTTPHeaders = []
//    headers["Authorization"] = "Bearer \(ThemeStoreAPI.bearerToken)"
    return headers
  }
}


