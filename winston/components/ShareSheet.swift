//
//  ShareSheet.swift
//  winston
//
//  Created by Daniel Inama on 31/08/23.
//

import SwiftUI
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
  var items: [Any]
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
    controller.title = "Test"
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    
  }
  
}

/// Image that you can share using a Share Sheet
/// This will also display all the metadata correctly
class ShareImage: UIActivityItemProvider {
  var image: UIImage
  
  override var item: Any {
    get {
      return self.image
    }
  }

  override init(placeholderItem: Any) {
    guard let image = placeholderItem as? UIImage else {
      fatalError("Couldn't create image from provided item")
    }

    self.image = image
    super.init(placeholderItem: placeholderItem)
  }

  @available(iOS 13.0, *)
  override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {

    let metadata = LPLinkMetadata()
    metadata.title = "Image"

    var thumbnail: NSSecureCoding = NSNull()
    if let imageData = self.image.pngData() {
      thumbnail = NSData(data: imageData)
    }

    metadata.imageProvider = NSItemProvider(item: thumbnail, typeIdentifier: "public.png")

    return metadata
  }

}
