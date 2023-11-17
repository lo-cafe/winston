//
//  fetchThemesByName.swift
//  winston
//
//  Created by Daniel Inama on 06/10/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func fetchThemesByName(name: String) async -> [ThemeData]? {
        if let headers = self.getRequestHeaders() {
            let response = await AF.request(
                "\(ThemeStoreAPI.baseURL)/themes/name/" + name,
                method: .get,
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

