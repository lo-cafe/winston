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
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)\(id.hasPrefix("/r/") ? id : "/r/\(id)/")about/rules.json?raw_json=1", method: .get, decodable: FetchSubRulesResponse.self)  {
    case .success(let data):
      return data
    case .failure(let error):
      print(error)
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
