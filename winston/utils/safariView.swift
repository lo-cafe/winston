//
//  safariView.swift
//  winston
//
//  Created by Daniel Inama on 08/09/23.
//

import Foundation
import SafariServices

func openInWebView(url: URL){
  var vc = SFSafariViewController(url: url)
  UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
}
