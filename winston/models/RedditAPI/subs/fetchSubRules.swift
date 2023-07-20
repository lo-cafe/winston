//
//  fetchSubRules.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchSubRules(_ id: String) async -> FetchSubRulesResponse? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)\(id.hasPrefix("/r/") ? id : "/r/\(id)/")about/rules.json",
        method: .get,
        headers: headers
      )
        .serializingDecodable(FetchSubRulesResponse.self).response
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
  
  struct FetchSubRulesRule: Codable {
    let kind: String?
    let description: String?
    let description_html: String?
    let short_name: String?
    let violation_reason: String?
    let created_utc: Int?
    let priority: Int?
  }
  
  struct FetchRedditRulesFlow: Codable {
    let complaintPrompt: String?
    let complaintButtonText: String?
    let complaintUrl: String?
    let complaintPageTitle: String?
    let nextStepHeader: String?
    let reasonTextToShow: String?
    let reasonText: String?
    let fileComplaint: Bool?
    let nextStepReasons: [FetchRedditRulesFlow]?
  }
  
  struct FetchSubRulesResponse: Codable {
    let rules: [FetchSubRulesRule]?
    let site_rules: [String]?
    let site_rules_flow: [FetchRedditRulesFlow]?
  }
}
