//
//  getDownloadURL.swift
//  winston
//
//  Created by Daniel Inama on 29/09/23.
//

import Foundation
import Alamofire

extension ThemeStoreAPI {
    func getDownloadedFilePath(filename: String, completion: @escaping (URL?) -> Void) {
        if let headers = self.getRequestHeaders() {
          let destination: DownloadRequest.Destination = { _, _ in
               let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
               let fileURL = tempDirectoryURL.appendingPathComponent(filename)
               return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
           }
            
            AF.download(
                "\(ThemeStoreAPI.baseURL)/themes/attachment/" + filename,
                method: .get,
                headers: headers,
                to: destination
            )
            .responseData { response in
                switch response.result {
                case .success:
                    if let destinationURL = response.fileURL {
                        completion(destinationURL)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
}

