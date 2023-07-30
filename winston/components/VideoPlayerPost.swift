import SwiftUI
import Defaults
import VideoPlayer
import CoreMedia
import AVKit

class SharedVideo: ObservableObject {
  @Published var time = CMTime()
  @Published var play = true
  @Published var player: AVPlayer
  
  init(player: AVPlayer) {
    self.player = player
  }
}

struct VideoPlayerPost: View {
  var post: Post
  var overrideWidth: CGFloat?
  @StateObject var sharedVideo: SharedVideo
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @State private var fullscreen = false
  @Namespace var namespace
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - (POSTLINK_OUTER_H_PAD * 2) - (preferenceShowPostsCards ? POSTLINK_INNER_H_PAD * 2 : 0) }
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    let media = post.data!.secure_media!
    switch media {
    case .first(let data):
      if let sourceWidth = data.reddit_video.width, let sourceHeight = data.reddit_video.height {
        let propHeight = (Int(contentWidth) * sourceHeight) / sourceWidth
        let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(Int(maxHeight), propHeight)) : Double(propHeight)
        ZStack {
          AVPlayerControllerRepresentable(showFullScreen: $fullscreen, player: sharedVideo.player, aspect: .resizeAspectFill)
            .allowsHitTesting(fullscreen)
            .frame(width: contentWidth, height: CGFloat(finalHeight))
            .mask(RR(12, .black))
            .contentShape(Rectangle())
            .onTapGesture {
              fullscreen = true
            }
            .onDisappear {
              sharedVideo.player.pause()
            }
            .onAppear {
              sharedVideo.player.play()
            }
        }
      } else {
        EmptyView()
      }
    case .second(_):
      EmptyView()
    }
  }
}

struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
  @Binding var showFullScreen: Bool
  let player: AVPlayer
  let aspect: AVLayerVideoGravity
  
  func makeUIViewController(context: Context) -> AVPlayerViewControllerRotatable {
    let controller  = AVPlayerViewControllerRotatable(willDismiss: self.willDismiss)
    controller.player = player
    controller.videoGravity = aspect
    chooseScreenType(controller: controller)
    return controller
  }
  
  func willDismiss() {
    showFullScreen = false
  }
  
  func updateUIViewController(_ controller: AVPlayerViewControllerRotatable, context content: Context) {
    chooseScreenType(controller: controller)
  }
  
  private func chooseScreenType(controller: AVPlayerViewControllerRotatable) {
    showFullScreen ? controller.enterFullScreen(animated: true) : controller.exitFullScreen(animated: true)
    controller.player?.play()
  }
}

class AVPlayerViewControllerRotatable: AVPlayerViewController, AVPlayerViewControllerDelegate {
  var willDismiss: () -> ()
  
  init(willDismiss: @escaping () -> Void) {
    self.willDismiss = willDismiss
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
  
  func playerViewController(
    _ playerViewController: AVPlayerViewController,
    willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate { _ in
      self.willDismiss()
    }
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if self.view.window == nil {
//      self.view.window?.windowScene?.keyWindow?.rootViewController?.present(self, animated: true)
//      print( self.view.window == nil, self.view.window?.windowScene == nil, self.view.window?.windowScene?.keyWindow? == nil, self.view.window?.windowScene?.keyWindow?.rootViewController? == nil)
//      UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
//    if self.isBeingDismissed || (self.isMovingFromParent && !self.isBeingPresented) {
//      print("AVPlayerViewController is being dismissed!")
//    }
  }
}

extension AVPlayerViewControllerRotatable {
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
}
