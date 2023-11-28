//
//  hideToggle.swift
//  winston
//
//  Created by Igor Marcossi on 14/08/23.
//

import Foundation
import Alamofire

private let queue = DispatchQueue(label: "lo.cafe.winston.hide.timer", attributes: .initiallyInactive)

private class HideDebouncer {
  static var shared = HideDebouncer()
  var workItem: DispatchWorkItem? = nil
  var names: [String] = []
}

extension RedditAPI {
  func hidePost(_ hide: Bool, fullnames: [String]) async -> () {
    HideDebouncer.shared.names += fullnames
    if HideDebouncer.shared.workItem != nil { return }
    HideDebouncer.shared.workItem = DispatchWorkItem {
      HideDebouncer.shared.workItem = nil
      let names = HideDebouncer.shared.names
      HideDebouncer.shared.names.removeAll()
      Task(priority: .background) {
        let params = HidePayload(id: names.joined(separator: ","))
        switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/\(hide ? "" : "un")hide", method: .post, params: params)  {
        case .success:
          //          return true
          break
        case .failure:
          //        print(error)
          //          return nil
          break
        }
      }
    }
    if let workItem = HideDebouncer.shared.workItem {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
  }
  
  struct HidePayload: Codable {
    let id: String
  }
}
