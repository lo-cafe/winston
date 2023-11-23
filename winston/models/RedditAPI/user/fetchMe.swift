//
//  fetchMe.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMe(force: Bool = false) async {
    var retryCount = 3 // Set your desired retry count
    while retryCount > 0 {
      do {
        try await attemptFetchMe(force: force)
        // If successful, break out of the loop
        break
      } catch {
        print("Error fetching me: \(error)")
        retryCount -= 1
        if retryCount == 0 {
          RedditAPI.shared.me = nil
        } else {
          // Add a delay before retrying (optional)
          do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
          } catch {
            // Handle the error or log it if necessary
            print("Error sleeping: \(error)")
          }
        }
      }
    }
  }

  private func attemptFetchMe(force: Bool) async throws {
    if !force, let me = me {
      RedditAPI.shared.me = me
    } else {
      await refreshToken()
      if let headers = self.getRequestHeaders() {
        let response = await AF.request(
          "\(RedditAPI.redditApiURLBase)/api/v1/me",
          method: .get,
          headers: headers
        )
        .serializingDecodable(UserData.self).response

        do {
          try await MainActor.run {
            switch response.result {
            case .success(let data):
              RedditAPI.shared.me = User(data: data, api: self)
            case .failure(let error):
              throw error
            }
          }
        } catch {
          // Handle the error or log it if necessary
          print("Error in MainActor.run: \(error)")
        }
      }
    }
  }
}

