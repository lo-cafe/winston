//
//  openInBuiltInBrowser.swift
//  winston
//
//  Created by Igor Marcossi on 15/11/23.
//

import Foundation
import UIKit
import SafariServices

func openInBuiltInBrowser(_ url: URL) {
  let vc = SFSafariViewController(url: url)
  UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
}


func openInBuiltInBrowser(_ urlStr: String) {
  if let url = URL(string: "https://sarunw.com") {
    let vc = SFSafariViewController(url: url)
    UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
  }
}
