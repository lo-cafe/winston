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
  var compact = false
  var overrideWidth: CGFloat?
  @StateObject var sharedVideo: SharedVideo
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @State private var firstFullscreen = false
  @State private var fullscreen = false
  @Default(.postLinksInnerHPadding) private var postLinksInnerHPadding
  @Default(.cardedPostLinksOuterHPadding) private var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksInnerHPadding) private var cardedPostLinksInnerHPadding
  @Default(.autoPlayVideos) private var autoPlayVideos
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - ((preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding) * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    let sourceWidth = sharedVideo.size.width
    let sourceHeight = sharedVideo.size.height
    let propHeight = (contentWidth * sourceHeight) / sourceWidth
    let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
    
    ZStack {
      if !fullscreen {
        VideoPlayer(player: sharedVideo.player)
          .aspectRatio(contentMode: .fill)
          .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
          .allowsHitTesting(false)
          .mask(RR(12, .black))
          .overlay(
            Color.clear
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation {
                  fullscreen = true
                }
              }
          )
      } else {
        Color.clear
          .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
      }
      Image(systemName: "play.fill").foregroundColor(.white.opacity(0.75)).fontSize(32).shadow(color: .black.opacity(0.45), radius: 12, y: 8).opacity(autoPlayVideos ? 0 : 1).allowsHitTesting(false)
    }
    .onChange(of: fullscreen) { val in
      if !firstFullscreen {
        firstFullscreen = true
        sharedVideo.player.play()
      }
      sharedVideo.player.volume = val ? 1.0 : 0.0
    }
    .onAppear {
      if autoPlayVideos {
        sharedVideo.player.play()
      }
    }
    .fullScreenCover(isPresented: $fullscreen) {
      FullScreenVP(sharedVideo: sharedVideo)
    }
  }
}

struct FullScreenVP: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var sharedVideo: SharedVideo
  @State private var drag: CGSize = .zero
  var body: some View {
    let interpolate = interpolatorBuilder([0, 100], value: abs(drag.height))
    VideoPlayer(player: sharedVideo.player)
      .scaleEffect(interpolate([1, 0.9], true))
      .offset(drag)
      .gesture(
        DragGesture(minimumDistance: 5)
          .onChanged { val in
            var transaction = Transaction()
            transaction.isContinuous = true
            transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
            
            var endPos = val.translation
            //                if dragAxis == .horizontal {
            //                  endPos.height = 0
            //                }
            withTransaction(transaction) {
              drag = endPos
            }
          }
          .onEnded { val in
            let shouldClose = abs(val.translation.width) > 100 || abs(val.translation.height) > 100
            print(abs(val.translation.width), abs(val.translation.height))
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20, initialVelocity: 0)) {
              drag = .zero
              if shouldClose {
                dismiss()
              }
            }
          }
      )
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
    if let playerController = controller.children[0] as? NiceAVPlayer, playerController.autoPlayVideos != autoPlayVideos {
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
  var ida = UUID().uuidString
  var gone = true
  override open var prefersStatusBarHidden: Bool {
    return true
  }
  
  init(autoPlayVideos: Bool) {
    self.autoPlayVideos = autoPlayVideos
    super.init(nibName: nil, bundle: nil)
    self.delegate = self
    showsPlaybackControls = false
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
    self.view.addGestureRecognizer(tapGesture)
    self.player?.play()
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.autoPlayVideos = false
    super.init(coder: aDecoder)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if autoPlayVideos && gone {
      self.player?.play()
      gone = false
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if !showsPlaybackControls {
      player?.pause()
      gone = true
    }
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
    coordinator.animate(alongsideTransition: nil) { context in
      if context.isCancelled {
        //        // Still full screen
      } else {
        //        // Embedded inline
        //        // Remove strong reference to playerViewController if held
        doThisAfter(0) {
          self.player?.volume = 0.0
        }
        self.showsPlaybackControls = false
        if !self.autoPlayVideos { self.player?.pause() } else if isPlaying { self.player?.play() }
      }
    }
  }
}
