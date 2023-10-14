//
//  uploadTheme.swift
//  winston
//
//  Created by Daniel Inama on 26/09/23.
//

import Foundation
import Alamofire

import Foundation
import Alamofire

extension ThemeStoreAPI {
  func uploadTheme(theme: WinstonTheme) async -> UploadResponse? {
    
    do {
      var zipURL: URL? = nil
      // Create a zip file with the theme's images
      createZipFile(with: [], theme: theme, completion: { url in
        zipURL = url
      })
      
      let headers: HTTPHeaders = [
        .authorization(bearerToken: ThemeStoreAPI.bearerToken)
      ]
      
      let response = await AF.upload(
        multipartFormData: { multipartFormData in
          multipartFormData.append(
            zipURL!,
            withName: "file",
            fileName: "theme.zip",
            mimeType: "application/zip"
          )
        },
        to: ThemeStoreAPI.baseURL + "/themes/upload",
        headers: headers
      )
        .uploadProgress { progress in
          // Handle upload progress updates if needed
        }
        .serializingDecodable(UploadResponse.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        Oops.shared.sendError(error)
        print(error)
        return nil
      }
      
    } catch {
      Oops.shared.sendError(error)
      print(error)
      return nil
    }
    return nil
  }
}



struct UploadResponse: Codable {
  var message: String?
}
