import SwiftUI
import Defaults
import CoreMedia
import AVKit
import AVFoundation
import Combine

class SharedVideoCache: ObservableObject {
  struct CacheItem {
    let video: SharedVideo
    let date: Date
  }
  
  static var shared = SharedVideoCache()
  @Published var cache: [String: CacheItem] = [:]
  let cacheLimit = 35
  
  func addKeyValue(key: String, url: URL, size: CGSize) {
    if !cache[key].isNil { return }
    //    Task(priority: .background) {
    // Create a new CacheItem with the current date
    let video = SharedVideo(url: url, size: size)
    let item = CacheItem(video: video, date: Date())
    let oldestKey = cache.count > cacheLimit ? cache.min { a, b in a.value.date < b.value.date }?.key : nil
    
    // Add the item to the cache
    //      await MainActor.run {
    withAnimation {
      cache[key] = item
      if let oldestKey = oldestKey { cache.removeValue(forKey: oldestKey) }
    }
    //      }
    //    }
  }
  
  private let _objectWillChange = PassthroughSubject<Void, Never>()
  
  var objectWillChange: AnyPublisher<Void, Never> { _objectWillChange.eraseToAnyPublisher() }
  
  subscript(key: String) -> CacheItem? {
    get { cache[key] }
    set {
      cache[key] = newValue
      _objectWillChange.send()
    }
  }
  
  func merge(_ dict: [String:CacheItem]) {
    cache.merge(dict) { (_, new) in new }
    _objectWillChange.send()
  }
}

//class SharedVideoCache

class SharedVideo: ObservableObject {
  @Published var player: AVPlayer
  @Published var url: URL
  @Published var size: CGSize
  
  init(url: URL, size: CGSize) {
    self.url = url
    self.size = size
    let newPlayer = AVPlayer(url: url)
    newPlayer.volume = 0.0
    self.player = newPlayer
  }
}

struct VideoPlayerPost: View {
  var controller: UIViewController?
  let markAsSeen: (() async -> ())?
  var compact = false
  var overrideWidth: CGFloat?
  var url: URL
  var size: CGSize
  @ObservedObject private var sharedVideoCache = SharedVideoCache.shared
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
  
  init(controller: UIViewController?, markAsSeen: (() async -> ())?, compact: Bool = false, overrideWidth: CGFloat? = nil, url: URL, size: CGSize) {
    self.controller = controller
    self.markAsSeen = markAsSeen
    self.compact = compact
    self.overrideWidth = overrideWidth
    self.url = url
    self.size = size
    SharedVideoCache.shared.addKeyValue(key: url.absoluteString, url: url, size: size)
  }
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - ((preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding) * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  var sharedVideo: SharedVideo? { sharedVideoCache[url.absoluteString]?.video }
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight)
    let sourceWidth = size.width
    let sourceHeight = size.height
    let propHeight = (contentWidth * sourceHeight) / sourceWidth
    let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
    
    //    ZStack {
    //      if !fullscreen {
    //        Group {
    //          if let sharedVideo = sharedVideo {
    //            VideoPlayer(player: sharedVideo.player)
    //              .scaledToFill()
    //          } else {
    //            ProgressView()
    //          }
    //        }
    if let controller = controller {
      AVPlayerRepresentable(fullscreen: $fullscreen, autoPlayVideos: autoPlayVideos, player: sharedVideo!.player, aspect: .resizeAspectFill, controller: controller)
        .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
        .mask(RR(12, Color.black))
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .highPriorityGesture(TapGesture().onEnded({ _ in
          if lightboxViewsPost { Task(priority: .background) { await markAsSeen?() } }
          withAnimation {
            fullscreen = true
          }
        }))
//        .onAppear {
//          if let sharedVideo = sharedVideo {
//            if loopVideos {
//              addObserver()
//            }
//            if autoPlayVideos {
//              sharedVideo.player.play()
//            }
//          }
//        }
//        .onDisappear() {
//          if let sharedVideo = sharedVideo {
//            removeObserver()
//            Task(priority: .background) {
//              sharedVideo.player.seek(to: .zero)
//              sharedVideo.player.pause()
//            }
//          }
//        }
//        .onChange(of: fullscreen) { val in
//          if let sharedVideo = sharedVideo {
//            if !firstFullscreen {
//              firstFullscreen = true
//              sharedVideo.player.play()
//            }
//            sharedVideo.player.volume = val ? 1.0 : 0.0
//          }
//        }
//        .fixedSize()
    }
    //        }
    //        .allowsHitTesting(false)
    //        .mask(RR(12, Color.black))
    //        .overlay(
    //          Color.clear
    //            .contentShape(Rectangle())
    //            .onTapGesture {
    //              if lightboxViewsPost { Task(priority: .background) { await markAsSeen?() } }
    //              withAnimation {
    //                fullscreen = true
    //              }
    //            }
    //        )
    //      }
    //      } else {
    //        Color.clear
    //          .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : CGFloat(finalHeight))
    //      }
    //      Image(systemName: "play.fill").foregroundColor(.white.opacity(0.75)).fontSize(32).shadow(color: .black.opacity(0.45), radius: 12, y: 8).opacity(autoPlayVideos ? 0 : 1).allowsHitTesting(false)
    //    }
    //    .onAppear {
    //      print(sharedVideo)
    //    }
//        .onAppear {
//          if let sharedVideo = sharedVideo {
//            if loopVideos {
//              addObserver()
//            }
//            if autoPlayVideos {
//              sharedVideo.player.play()
//            }
//          }
//        }
//        .onDisappear() {
//          if let sharedVideo = sharedVideo {
//            removeObserver()
//            Task(priority: .background) {
//              sharedVideo.player.seek(to: .zero)
//              sharedVideo.player.pause()
//            }
//          }
//        }
//        .onChange(of: fullscreen) { val in
//          if let sharedVideo = sharedVideo {
//            if !firstFullscreen {
//              firstFullscreen = true
//              sharedVideo.player.play()
//            }
//            sharedVideo.player.volume = val ? 1.0 : 0.0
//          }
//        }
    //    .fullScreenCover(isPresented: $fullscreen) {
    //      if let sharedVideo = sharedVideo {
    //        FullScreenVP(sharedVideo: sharedVideo)
    //      }
    //    }
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
    }
  }
  
  func removeObserver() {
    if let sharedVideo = sharedVideo {
      NotificationCenter.default.removeObserver(
        self,
        name: .AVPlayerItemDidPlayToEndTime,
        object: sharedVideo.player.currentItem)
    }
  }
}

struct FullScreenVP: View {
  @ObservedObject var sharedVideo: SharedVideo
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
            if cancelDrag.isNil { cancelDrag = abs(val.translation.width) > abs(val.translation.height) }
            if cancelDrag.isNil || cancelDrag! { return }
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
            if prevCancelDrag.isNil || prevCancelDrag! { return }
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
        if let playerController = context.coordinator.controller {
          if fullscreen {
            playerController.enterFullScreen(animated: true)
          }
        }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator: NSObject {
    var controller: NiceAVPlayer? = nil
  }
  
  //  func makeCoordinator() -> Coordinator {
  //    Coordinator(parent: self)
  //  }
  //
  //  class Coordinator: NSObject, AVPlayerViewControllerDelegate {
  //    private var parent: AVPlayerControllerRepresentable
  //
  //    init(parent: AVPlayerControllerRepresentable) {
  //      self.parent = parent
  //    }
  //
  //
  //  }
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
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
//    self.view.addGestureRecognizer(tapGesture)
//    self.player?.play()
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
        queue: nil) { notif in
          Task(priority: .background) {
            player.seek(to: .zero)
            player.play()
          }
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
        self.fullscreen = false
        doThisAfter(0) {
          self.player?.volume = 0.0
        }
        self.showsPlaybackControls = false
        if !self.autoPlayVideos { self.player?.pause() } else if isPlaying { self.player?.play() }
      }
    }
  }
}
