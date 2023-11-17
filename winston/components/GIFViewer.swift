//
//  GIFViewer.swift
//  winston
//
//  Created by Igor Marcossi on 29/10/23.
//

import SwiftUI
import NukeUI
import Nuke
import Gifu

/// An image view for displaying animated images.
public struct GIFImage: UIViewRepresentable {
  private enum Source {
    case data(Data)
    case url(URL)
    case imageName(String)
  }
  
  private let source: Source
  private var loopCount = 0
  
  /// Initializes the view with the given GIF image data.
  public init(data: Data) {
    self.source = .data(data)
  }
  
  /// Initialzies the view with the given GIF image url.
  public init(url: URL) {
    self.source = .url(url)
  }
  
  /// Initialzies the view with the given GIF image name.
  public init(imageName: String) {
    self.source = .imageName(imageName)
  }
  
  /// Sets the desired number of loops. By default, the number of loops infinite.
  public func loopCount(_ value: Int) -> GIFImage {
    var copy = self
    copy.loopCount = value
    return copy
  }
  
  public func makeUIView(context: Context) -> GIFImageView {
    GIFImageView(frame: .zero)
  }
  
  public func updateUIView(_ view: GIFImageView, context: Context) {
    switch source {
    case .data(let data):
      view.animate(withGIFData: data, loopCount: loopCount)
    case .url(let url):
      view.animate(withGIFURL: url, loopCount: loopCount)
    case .imageName(let imageName):
      view.animate(withGIFNamed: imageName, loopCount: loopCount)
    }
  }
  
  public static func dismantleUIView(
      _ uiView: GIFImageView,
      coordinator: Coordinator
  ) {
    uiView.prepareForReuse()
  }
}

class LoadingImgView: UIImageView {
  init() {
    let loadingImg = UIImage(named: "loader")
    super.init(image: loadingImg)
    self.frame = .init(origin: .zero, size: CGSize(width: 75, height: 75))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
