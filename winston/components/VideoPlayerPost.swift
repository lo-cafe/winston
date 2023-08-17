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
    newPlayer.isMuted = true
    self.player = newPlayer
  }
}

struct VideoPlayerPost: View {
  var overrideWidth: CGFloat?
  @StateObject var sharedVideo: SharedVideo
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  @State private var fullscreen = false
  @State private var initialized = false
  @Default(.postLinksInnerHPadding) private var postLinksInnerHPadding
  @Default(.cardedPostLinksOuterHPadding) private var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksInnerHPadding) private var cardedPostLinksInnerHPadding

  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  var rawContentWidth: CGFloat { UIScreen.screenWidth - (preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  var body: some View {
    let contentWidth = overrideWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    let sourceWidth = sharedVideo.size.width
    let sourceHeight = sharedVideo.size.height
    let propHeight = (contentWidth * sourceHeight) / sourceWidth
    let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
    
    AVPlayerControllerRepresentable(showFullScreen: $fullscreen, player: sharedVideo.player, url:sharedVideo.url, aspect: .resizeAspectFill)
      .allowsHitTesting(fullscreen)
      .frame(width: contentWidth, height: CGFloat(finalHeight))
      .mask(RR(12, .black))
      .contentShape(Rectangle())
      .onChange(of: fullscreen) { val in
        sharedVideo.player.isMuted = !val
      }
      .onTapGesture {
        fullscreen = true
      }
      .onAppear {
        if !initialized {
          sharedVideo.player.play()
          initialized = true
        }
      }
    //            .id(uuid)
  }
}

struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
  @Binding var showFullScreen: Bool
  let player: AVPlayer
  var url: URL
  let aspect: AVLayerVideoGravity
  
  func makeUIViewController(context: Context) -> AVPlayerViewControllerRotatable {
    let controller = AVPlayerViewControllerRotatable(url: url)
    controller.view.window?.rootViewController = UIApplication.shared.rootViewController
    controller.player = player
    controller.videoGravity = aspect
    
    context.coordinator.playerController = controller
    chooseScreenType(controller: controller)
    return controller
  }
  
  func willDismiss() {
    showFullScreen = false
  }
  
  func updateUIViewController(_ controller: AVPlayerViewControllerRotatable, context content: Context) {
    chooseScreenType(controller: controller)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private func chooseScreenType(controller: AVPlayerViewControllerRotatable) {
    showFullScreen ? controller.enterFullScreen(animated: true) : controller.exitFullScreen(animated: true)
  }
  
  class Coordinator: NSObject, AVPlayerViewControllerDelegate {
    private var parent: AVPlayerControllerRepresentable
    weak var playerController: AVPlayerViewController? {
      didSet {
        playerController?.delegate = self
      }
    }
    
    init(parent: AVPlayerControllerRepresentable) {
      self.parent = parent
    }
    
    func playerViewController(
      _ playerViewController: AVPlayerViewController,
      willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
      let isPlaying = parent.player.isPlaying
      coordinator.animate { _ in
        self.parent.willDismiss()
      }
      coordinator.animate(alongsideTransition: nil) { transitionContext in
        if isPlaying { self.parent.player.play() }
      }
    }
  }
}

//class AVPlayerViewControllerRotatable: AVPlayerViewController, AVPlayerViewControllerDelegate, AVAssetDownloadDelegate {
class AVPlayerViewControllerRotatable: AVPlayerViewController {
  var observer: NSKeyValueObservation? = nil
  var url: URL
  
  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
    //    self.view.window?.rootViewController =
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  //  func setupAssetDownload() {
  //    // Create new background session configuration.
  //    let configuration = URLSessionConfiguration.background(withIdentifier: "AssetIDasas")
  //
  //    // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
  //    let downloadSession = AVAssetDownloadURLSession(
  //      configuration: configuration,
  //      assetDownloadDelegate: self,
  //      delegateQueue: OperationQueue.main
  //    )
  //
  //    let asset = AVURLAsset(url: self.url)
  //
  //    // Create new AVAssetDownloadTask for the desired asset
  //    let downloadTask = downloadSession.makeAssetDownloadTask(
  //      asset: asset,
  //      assetTitle: "AssetTitlesasaqsq",
  //      assetArtworkData: nil,
  //      options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: NSNumber(value: 0)]
  //    )
  //    // Start task and begin download
  //    downloadTask?.resume()
  //    print("asmo")
  //  }
  
  //  public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL){
  //          print("DownloadedLocation:\(location.absoluteString)")
  //      }
  //
  //      public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
  //        debugPrint("Task completed: \(task), error: \(String(describing: error))")
  //      }
  //
  //      public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
  //          print("Error invalid", error)
  //      }
  //
  //      public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
  //          print("Waiting")
  //      }
  //
  //      public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
  //          print("Finish collecting metrics:")
  //      }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    //    self.view.window?.rootViewController = UIApplication.shared.windows.first?.rootViewController
    super.viewDidAppear(animated)
    
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
    //    self.view.window?.rootViewController?.present(self, animated: true)
    let selector = NSSelectorFromString("enterFullScreenAnimated:completionHandler:")
    
    if self.responds(to: selector) {
      self.perform(selector, with: animated, with: nil)
      
      //      try? AVAudioSession.sharedInstance().setActive(false)
      //      try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowAirPlay, .allowBluetooth, .duckOthers, .allowBluetoothA2DP, .defaultToSpeaker])
      //      try? AVAudioSession.sharedInstance().setActive(true)
    }
  }
  
  func exitFullScreen(animated: Bool) {
    //    self.view.window?.rootViewController?.present(self, animated: true)
    let selector = NSSelectorFromString("exitFullScreenAnimated:completionHandler:")
    //    try? AVAudioSession.sharedInstance().setActive(false)
    if self.responds(to: selector) {
      self.perform(selector, with: animated, with: nil)
    }
  }
}
