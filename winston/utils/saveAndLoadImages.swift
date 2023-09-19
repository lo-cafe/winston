//
//  saveAndLoadImages.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import SwiftUI
import Zip

func saveImage(image: UIImage) -> String? {
  guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
  
  let id = UUID().uuidString
//  let fileName = id
  var data: Data?
  var ext: String?
  if let newData = image.jpegData(compressionQuality: 1) {
    data = newData
    ext = "jpg"
  }
  if let newData = image.pngData() {
    data = newData
    ext = "png"
  }
  guard let data = data, let ext = ext else { return nil }
  
  let fileURL = documentsDirectory.appendingPathComponent("\(id).\(ext)")
  
  //Checks if file exists, removes it if so.
  if FileManager.default.fileExists(atPath: fileURL.path) {
    do {
      try FileManager.default.removeItem(atPath: fileURL.path)
      print("Removed old image")
    } catch let removeError {
      print("couldn't remove file at path", removeError)
    }
  }
  
  do {
    try data.write(to: fileURL)
    return "\(id).\(ext)"
  } catch let error {
    print("error saving file with error", error)
    return nil
  }
}


func loadImage(fileName: String) -> UIImage? {
  let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
  
  let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
  let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
  
  if let dirPath = paths.first {
    let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
    let image = UIImage(contentsOfFile: imageUrl.path)
    return image
  }
  
  return nil
}

func loadImageURL(fileName: String) -> URL? {
  let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
  
  let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
  let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
  
  if let dirPath = paths.first {
    let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
    return imageUrl
  }
  
  return nil
}


//struct ZipDocument: FileDocument {
//    static var readableContentTypes = [UTType.zip]
//    var zipfile: URL
//
//    init(url: URL) {
//        self.zipfile = url
//    }
//
//    init(configuration: ReadConfiguration) throws {
//        // We don't read files, so we just need to fulfill the requirements of the protocol here, no actual implementation.
//        throw CocoaError(.fileReadCorruptFile)
//    }
//
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        return try FileWrapper(url: zipfile, options: .immediate)
//    }
//}

func createZip(images: [String], theme: WinstonTheme) throws -> URL {
  let fileManager = FileManager.default
  let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
  
  guard let documentDirectory: URL = urls.first else { throw NSError(domain: "Document directory not found", code: 1, userInfo: nil) }
  
  let imgURLs = images.filter { $0 != "winstonNoBG" }.map { documentDirectory.appendingPathComponent($0) }
  
  let jsonURL = documentDirectory.appendingPathComponent("theme.json")
  let jsonData = try JSONEncoder().encode(theme)
  try jsonData.write(to: jsonURL)
  
  let zipName = "\(theme.metadata.name) Theme - Winston"
  let zipURL = documentDirectory.appendingPathComponent("\(zipName).zip")
  
  if fileManager.fileExists(atPath: zipURL.path()) {
    try fileManager.removeItem(at: zipURL)
  }
  
  print(fileManager.fileExists(atPath: imgURLs[0].path()))
  
  let zipFilePath = try Zip.quickZipFiles(imgURLs + [jsonURL], fileName: zipName)
  // replace with your ZipArchive class and its usage
  // make sure theme.json and images are added to the zip file
  
  return zipFilePath
}
