//
//  MediaUtils.swift
//  winston
//
//  Created by Ethan Bills on 1/24/24.
//

import Foundation
import Photos

class MediaUtils {
  
  static func downloadVideo(videoURL: URL) {
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    
    let downloadTask = session.downloadTask(with: videoURL) { (url, response, error) in
      guard error == nil, let url = url else {
        print("Error downloading video:", error?.localizedDescription ?? "")
        return
      }
      
      saveVideoToAlbum(videoURL: url, albumName: "Winston")
    }
    
    downloadTask.resume()
  }
  
  private static func saveVideoToAlbum(videoURL: URL, albumName: String) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
    
    if let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
      saveVideo(videoURL: videoURL, to: album)
    } else {
      createAlbumAndSave(videoURL: videoURL, albumName: albumName)
    }
  }
  
  private static func saveVideo(videoURL: URL, to album: PHAssetCollection) {
    PHPhotoLibrary.shared().performChanges({
      let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
      let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
      
      if let placeholder = assetChangeRequest?.placeholderForCreatedAsset {
        albumChangeRequest?.addAssets([placeholder] as NSArray)
      }
      
    }, completionHandler: { success, error in
      if success {
        print("Successfully saved video to album")
      } else {
        print("Error saving video to album:", error?.localizedDescription ?? "")
      }
    })
  }
  
  private static func createAlbumAndSave(videoURL: URL, albumName: String) {
    var albumPlaceholder: PHObjectPlaceholder?
    
    PHPhotoLibrary.shared().performChanges({
      let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
      albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
    }, completionHandler: { success, error in
      if success, let albumPlaceholder = albumPlaceholder {
        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
        
        if let album = collectionFetchResult.firstObject {
          saveVideo(videoURL: videoURL, to: album)
        }
      } else {
        print("Error creating album:", error?.localizedDescription ?? "")
      }
    })
  }
}
