import SafariServices
import SwiftUI

struct SafariViewPayload: Hashable {
  let url: URL
  let useReader: Bool
}

class DoneButtonHandler: NSObject, SFSafariViewControllerDelegate {
  var dismissAction: (() -> ())? = nil

  init(dismissAction: @escaping () -> ()) {
    self.dismissAction = dismissAction
  }
  
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismissAction?()
  }
}

var dismissHandler: DoneButtonHandler?

struct SafariView: UIViewControllerRepresentable {
  
  @EnvironmentObject private var router: Router
  
  let payload:  SafariViewPayload
  
  func goBack() {
    router.path.removeLast()
  }
  

  func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = payload.useReader
    let vc = SFSafariViewController(url: payload.url, configuration: config)
    dismissHandler = DoneButtonHandler(dismissAction: goBack)
    vc.delegate = dismissHandler
    return vc
  }

  func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
