import SwiftUI
import Defaults
import CoreMedia
import AVKit
import AVFoundation
import Combine

struct SharedVideo: Equatable {
  static func == (lhs: SharedVideo, rhs: SharedVideo) -> Bool {
    lhs.url == rhs.url && lhs.player.currentItem == rhs.player.currentItem
  }
  
  var player: AVPlayer
  var url: URL
  var size: CGSize
  
  static func get(url: URL, size: CGSize) -> SharedVideo {
    let cacheKey =  SharedVideo.cacheKey(url: url, size: size)
    
    if let sharedVideo = Caches.videos.get(key: cacheKey) {
      return sharedVideo
    } else {
      let sharedVideo = SharedVideo(url: url, size: size)
      Caches.videos.addKeyValue(key: cacheKey, data: { sharedVideo }, expires: Date().dateByAdding(1, .day).date)
      
      return sharedVideo
    }
  }
  
  func resetPlayer() {
    player.replaceCurrentItem(with: AVPlayerItem(url: url))
  }
  
  static func cacheKey(url: URL, size: CGSize) -> String {
    return "\(url.absoluteString):\(size.width)x\(size.height)"
  }
  
  init(url: URL, size: CGSize) {
    self.url = url
    self.size = size
    let newPlayer = AVPlayer(url: url)
    newPlayer.volume = 0.0
    self.player = newPlayer
  }
}

struct VideoPlayerPost: View, Equatable {
  static func == (lhs: VideoPlayerPost, rhs: VideoPlayerPost) -> Bool {
    lhs.url == rhs.url && lhs.sharedVideo == rhs.sharedVideo
  }
  
  weak var controller: UIViewController?
  var sharedVideo: SharedVideo?
  let markAsSeen: (() async -> ())?
  var compact = false
  var overrideWidth: CGFloat?
  var url: URL
  var size: CGSize
  @State private var firstFullscreen = false
  @State private var fullscreen = false
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) private var maxPostLinkImageHeightPercentage
  @Default(.postLinksInnerHPadding) private var postLinksInnerHPadding
  @Default(.cardedPostLinksOuterHPadding) private var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksInnerHPadding) private var cardedPostLinksInnerHPadding
  @Default(.autoPlayVideos) private var autoPlayVideos
  @Default(.loopVideos) private var loopVideos
  @Default(.lightboxViewsPost) private var lightboxViewsPost
	@Default(.muteVideos) private var muteVideos
  
  init(controller: UIViewController?, cachedVideo: SharedVideo?, markAsSeen: (() async -> ())?, compact: Bool = false, overrideWidth: CGFloat? = nil, url: URL) {
    self.controller = controller
    self.sharedVideo = cachedVideo
    self.markAsSeen = markAsSeen
    self.compact = compact
    self.overrideWidth = overrideWidth
    self.url = url
    self.size = cachedVideo?.size ?? .zero
  }
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - ((preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding) * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight)
    let sourceWidth = size.width
    let sourceHeight = size.height
    let propHeight = (contentWidth * sourceHeight) / sourceWidth
    let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
    
    if let sharedVideo = sharedVideo {
      if let controller = controller {
        AVPlayerRepresentable(fullscreen: $fullscreen, autoPlayVideos: autoPlayVideos, player: sharedVideo.player, aspect: .resizeAspectFill, controller: controller)
          .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
          .mask(RR(12, Color.black))
          .allowsHitTesting(false)
          .contentShape(Rectangle())
          .onTapGesture {
            if lightboxViewsPost { Task(priority: .background) { await markAsSeen?() } }
            withAnimation {
              fullscreen = true
            }
          }
      } else {
        ZStack {
          
          Group {
            if !fullscreen {
              VideoPlayer(player: sharedVideo.player)
                .scaledToFill()
            } else {
              Color.clear
            }
          }
          .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
          .clipped()
          .fixedSize()
          .mask(RR(12, Color.black))
          .allowsHitTesting(false)
          .contentShape(Rectangle())
          .highPriorityGesture(TapGesture().onEnded({ _ in
            if lightboxViewsPost { Task(priority: .background) { await markAsSeen?() } }
            withAnimation {
              fullscreen = true
            }
          }))
          .onChange(of: fullscreen) { val in
            if !firstFullscreen {
              firstFullscreen = true
							sharedVideo.player.isMuted = muteVideos
              sharedVideo.player.play()
            }
						if !val && !autoPlayVideos {
							sharedVideo.player.seek(to: .zero)
							sharedVideo.player.pause()
							firstFullscreen = false
						}
            sharedVideo.player.volume = val ? 1.0 : 0.0
          }
          .allowsHitTesting(false)
          .mask(RR(12, Color.black))
          .overlay(
            Color.clear
              .contentShape(Rectangle())
              .onTapGesture {
                if lightboxViewsPost { Task(priority: .background) { await markAsSeen?() } }
                withAnimation {
                  fullscreen = true
                }
              }
          )
          
          Image(systemName: "play.fill").foregroundColor(.white.opacity(0.75)).fontSize(32).shadow(color: .black.opacity(0.45), radius: 12, y: 8).opacity(autoPlayVideos ? 0 : 1).allowsHitTesting(false)
        }
        .onAppear {
          if loopVideos {
            addObserver()
          }
          if autoPlayVideos {
            sharedVideo.player.play()
          }
        }
        .onDisappear() {
          removeObserver()
          Task(priority: .background) {
            sharedVideo.player.seek(to: .zero)
            sharedVideo.player.pause()
          }
        }
        .onChange(of: fullscreen) { val in
          if !firstFullscreen {
            firstFullscreen = true
						sharedVideo.player.isMuted = muteVideos
            sharedVideo.player.play()
          } 
					if !val && !autoPlayVideos {
						sharedVideo.player.seek(to: .zero)
						sharedVideo.player.pause()
						firstFullscreen = false
					 }
          sharedVideo.player.volume = val ? 1.0 : 0.0
        }
        .fullScreenCover(isPresented: $fullscreen) {
          FullScreenVP(sharedVideo: sharedVideo)
        }
      }
    }
  }
  
  func addObserver() {
    if let sharedVideo = sharedVideo {
      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: sharedVideo.player.currentItem,
        queue: nil) { notif in
          Task(priority: .background) {
            sharedVideo.player.seek(to: .zero)
            sharedVideo.player.play()
          }
        }
      
      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemFailedToPlayToEndTime,
        object: sharedVideo.player.currentItem,
        queue: nil) { notif in
          Task(priority: .background) {
            DispatchQueue.main.async {
              sharedVideo.resetPlayer()
            }
          }
        }
    }
  }
  
  func removeObserver() {
    if let sharedVideo = sharedVideo {
      NotificationCenter.default.removeObserver(
        self,
        name: .AVPlayerItemDidPlayToEndTime,
        object: sharedVideo.player.currentItem)
      
      NotificationCenter.default.removeObserver(
        self,
        name: .AVPlayerItemFailedToPlayToEndTime,
        object: sharedVideo.player.currentItem)
    }
  }
}

struct FullScreenVP: View {
  var sharedVideo: SharedVideo
  @Environment(\.dismiss) private var dismiss
  @State private var cancelDrag: Bool?
  @State private var isPinching: Bool = false
  @State private var drag: CGSize = .zero
  @State private var scale: CGFloat = 1.0
  @State private var anchor: UnitPoint = .zero
  @State private var offset: CGSize = .zero
  @State private var altSize: CGSize = .zero
  var body: some View {
    let interpolate = interpolatorBuilder([0, 100], value: abs(drag.height))
    VideoPlayer(player: sharedVideo.player)
      .background(
        sharedVideo.size != .zero
        ? nil
        : GeometryReader { geo in
          Color.clear
            .onAppear { altSize = geo.size }
            .onChange(of: geo.size) { newValue in altSize = newValue }
        }
      )
    //      .pinchToZoom(size: sharedVideo.size == .zero ? altSize : sharedVideo.size, isPinching: $isPinching, scale: $scale, anchor: $anchor, offset: $offset)
      .scaleEffect(interpolate([1, 0.9], true))
      .offset(cancelDrag ?? false ? .zero : drag)
      .gesture(
        scale != 1.0
        ? nil
        : DragGesture(minimumDistance: 10)
          .onChanged { val in
            if cancelDrag == nil { cancelDrag = abs(val.translation.width) > abs(val.translation.height) }
            if cancelDrag == nil || cancelDrag! { return }
            var transaction = Transaction()
            transaction.isContinuous = true
            transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
            
            let endPos = val.translation
            withTransaction(transaction) {
              drag = endPos
            }
          }
          .onEnded { val in
            let prevCancelDrag = cancelDrag
            cancelDrag = nil
            if prevCancelDrag == nil || prevCancelDrag! { return }
            let shouldClose = abs(val.translation.width) > 100 || abs(val.translation.height) > 100
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

struct AVPlayerRepresentable: UIViewRepresentable {
  @Binding var fullscreen: Bool
  var autoPlayVideos: Bool
  let player: AVPlayer
  let aspect: AVLayerVideoGravity
  var controller: UIViewController

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    let playerController = NiceAVPlayer(fullscreen: $fullscreen, autoPlayVideos: autoPlayVideos)
    playerController.allowsVideoFrameAnalysis = false
    playerController.player = player
    playerController.videoGravity = aspect

    context.coordinator.controller = playerController
    controller.addChild(playerController)
    playerController.view.frame = view.bounds
    view.addSubview(playerController.view)
    playerController.didMove(toParent: controller)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return view
  }

  func updateUIView(_ view: UIView, context: Context) {
    if let playerController = context.coordinator.controller, playerController.autoPlayVideos != autoPlayVideos {
      playerController.autoPlayVideos = autoPlayVideos
    }
    if fullscreen {
      context.coordinator.controller?.enterFullScreen(animated: true)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator: NSObject {
    var controller: NiceAVPlayer? = nil
  }
}

class NiceAVPlayer: AVPlayerViewController, AVPlayerViewControllerDelegate {
  @Binding var fullscreen: Bool
  var autoPlayVideos: Bool
  var ida = UUID().uuidString
  var gone = true
  @Default(.loopVideos) private var loopVideos
  override open var prefersStatusBarHidden: Bool {
    return true
  }

  init(fullscreen: Binding<Bool>, autoPlayVideos: Bool) {
    self._fullscreen = fullscreen
    self.autoPlayVideos = autoPlayVideos
    super.init(nibName: nil, bundle: nil)
    self.delegate = self
    showsPlaybackControls = false
  }

  required init?(coder aDecoder: NSCoder) {
    self.autoPlayVideos = false
    self._fullscreen = Binding(get: { true }, set: { _, _ in false })
    super.init(coder: aDecoder)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if loopVideos, let player = self.player {
      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: player.currentItem,
        queue: nil) { [weak self] notif in
          guard let self = self else { return }
          player.seek(to: .zero)
          player.play()
        }
    }
    if autoPlayVideos && gone {
      self.player?.play()
      gone = false
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if let player = self.player {
      NotificationCenter.default.removeObserver(
        self,
        name: .AVPlayerItemDidPlayToEndTime,
        object: player.currentItem)
    }
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
    coordinator.animate(alongsideTransition: nil) { [weak self] context in
      guard let self = self else { return }
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
    coordinator.animate(alongsideTransition: nil) { [weak self] context in
      guard let self = self else { return }
      if context.isCancelled {
        // Still full screen
      } else {
        // Embedded inline
        // Remove strong reference to playerViewController if held
        self.fullscreen = false
        doThisAfter(0.0) {
          self.player?.volume = 0.0
        }
        self.showsPlaybackControls = false
        if !self.autoPlayVideos { self.player?.pause() } else if isPlaying { self.player?.play() }
      }
    }
  }
}

extension AVPlayer {
  var isVideoPlaying: Bool {
    return rate != 0 && error == nil
  }
}
