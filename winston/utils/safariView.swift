//
//  safariView.swift
//  winston
//
//  Created by Daniel Inama on 08/09/23.
//

import Foundation
import SafariServices
import Defaults
import SwiftUI

func openInWebView(url: URL){

  let vcConfig = SFSafariViewController.Configuration()
  vcConfig.entersReaderIfAvailable = Defaults[.useReaderMode]
  var vc = SFSafariViewController(url: url, configuration: vcConfig)
  
  if Defaults[.useBuiltInBrowser] {
   UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
  } else {
    @Environment(\.openURL) var openURL
    openURL(url)
  }
}
