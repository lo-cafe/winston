//
//  fetchThemeByID.swift
//  winston
//
//  Created by Daniel Inama on 08/11/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func fetchThemeByID(id: String) async -> ThemeData? {
        if let headers = self.getRequestHeaders() {
            let response = await AF.request(
                "\(ThemeStoreAPI.baseURL)/themes/" + id,
                method: .get,
                headers: headers
            )
            .serializingDecodable(ThemeData.self).response
            
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
}
