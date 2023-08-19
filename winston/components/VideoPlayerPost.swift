import SwiftUI
import Defaults
import CoreMedia
import AVKit
import AVFoundation

class SharedVideo: ObservableObject {
  @Published var player: AVPlayer
  @Published var size: CGSize
  @Published var url: URL
  
  init(url: URL, size: CGSize) {
    self.url = url
    self.size = size
    let newPlayer = AVPlayer(url: url)
    newPlayer.volume = 0.0
    self.player = newPlayer
  }
}

struct VideoPlayerPost: View {
  var overrideWidth: CGFloat?
  @StateObject var sharedVideo: SharedVideo
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @State private var initialized = false
  @State var willBeginFullScreenPresentation: Bool = false
  @Default(.postLinksInnerHPadding) private var postLinksInnerHPadding
  @Default(.cardedPostLinksOuterHPadding) private var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksInnerHPadding) private var cardedPostLinksInnerHPadding
  @Default(.autoPlayVideos) private var autoPlayVideos
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - (preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    let sourceWidth = sharedVideo.size.width
    let sourceHeight = sharedVideo.size.height
    let propHeight = (contentWidth * sourceHeight) / sourceWidth
    let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
    
    AVPlayerControllerRepresentable(autoPlayVideos: autoPlayVideos, player: sharedVideo.player, aspect: .resizeAspectFill)
      .shadow(radius: 0)
      .ignoresSafeArea()
      .frame(width: contentWidth, height: CGFloat(finalHeight))
      .mask(RR(12, .black))
      .gesture(TapGesture())
      .contentShape(Rectangle())
      .overlay(sharedVideo.player.isPlaying ? nil : Image(systemName: "play.fill").foregroundColor(.white.opacity(0.75)).fontSize(32).shadow(color: .black.opacity(0.45), radius: 12, y: 8).allowsHitTesting(false))
      .onAppear {
        if autoPlayVideos && !initialized {
          sharedVideo.player.play()
          withAnimation {
            initialized = true
          }
        }
      }
  }
}

struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
  var autoPlayVideos: Bool
  let player: AVPlayer
  let aspect: AVLayerVideoGravity
  
  func makeUIViewController(context: Context) -> UIViewController {
    let controller = UIViewController()
    let playerController = NiceAVPlayer(autoPlayVideos: autoPlayVideos)
    playerController.allowsVideoFrameAnalysis = false
    playerController.player = player
    playerController.videoGravity = aspect
    
    controller.addChild(playerController)
    controller.view.addSubview(playerController.view)
    playerController.didMove(toParent: controller)
    
    return controller
  }
  
  func updateUIViewController(_ controller: UIViewController, context content: Context) {
    
    if let playerController = controller.children[0] as? NiceAVPlayer {
      playerController.autoPlayVideos = autoPlayVideos
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  class Coordinator: NSObject, AVPlayerViewControllerDelegate {
    private var parent: AVPlayerControllerRepresentable
    
    init(parent: AVPlayerControllerRepresentable) {
      self.parent = parent
    }
    
    
  }
}

class NiceAVPlayer: AVPlayerViewController, AVPlayerViewControllerDelegate {
  var autoPlayVideos: Bool
  override open var prefersStatusBarHidden: Bool {
    return true
  }
  
  init(autoPlayVideos: Bool) {
    self.autoPlayVideos = autoPlayVideos
    super.init(nibName: nil, bundle: nil)
    self.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.autoPlayVideos = false
    super.init(coder: aDecoder)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    showsPlaybackControls = false
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
    self.view.addGestureRecognizer(tapGesture)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  @objc private func didTapView() {
    enterFullScreen(animated: true)
    showsPlaybackControls = true
  }
  
  func enterFullScreen(animated: Bool) {
    let selector = NSSelectorFromString("enterFullScreenAnimated:completionHandler:")
    
    if self.responds(to: selector) {
      self.perform(selector, with: animated, with: nil)
    }
  }
  
  func exitFullScreen(animated: Bool) {
    let selector = NSSelectorFromString("exitFullScreenAnimated:completionHandler:")
    
    if self.responds(to: selector) {
      self.perform(selector, with: animated, with: nil)
    }
  }
  
  func playerViewController(
    _ playerViewController: AVPlayerViewController,
    willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
  ) {
    let isPlaying = playerViewController.player?.isPlaying ?? false
    coordinator.animate(alongsideTransition: nil) { context in
      if context.isCancelled {
        // Still embedded inline
      } else {
        // Presented full screen
        // Take strong reference to playerViewController if needed
        self.player?.volume = 1.0
        self.player?.play()
        self.showsPlaybackControls = true
      }
    }
  }
  
  func playerViewController(
    _ playerViewController: AVPlayerViewController,
    willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
  ) {
    let isPlaying = self.player?.isPlaying ?? false
    coordinator.animate { _ in
      self.player?.volume = 0.0
      self.showsPlaybackControls = false
    }
    coordinator.animate(alongsideTransition: nil) { context in
      if context.isCancelled {
        // Still full screen
      } else {
        // Embedded inline
        // Remove strong reference to playerViewController if held
        if !self.autoPlayVideos { self.player?.pause() } else if isPlaying { self.player?.play() }
      }
    }
  }
}
