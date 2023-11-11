//
//  fetchAllThemes.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
    func fetchAllThemes(fetchLimit: Int? = nil, offset: Int? = nil) async -> [ThemeData]? {
        if let headers = self.getRequestHeaders() {
            let parameters: [String: Any] = [
              "fetchLimit": fetchLimit ?? 100,
              "offset": offset == nil ?? 0
            ]
            
            let response = await AF.request(
                "\(ThemeStoreAPI.baseURL)/themes",
                method: .get,
                parameters: parameters,
                headers: headers
            )
            .serializingDecodable([ThemeData].self).response
            
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
}

