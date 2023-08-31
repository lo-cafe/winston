//
//  safariWebView.swift
//  winston
//
//  Created by Daniel Inama on 31/08/23.
//

import SwiftUI
import SafariServices

func openURLInWebView(url: URL){
  // Present SFSafariViewController
  let safariVC = SFSafariViewController(url: url)
  UIApplication.shared.rootViewController?.present(safariVC, animated: true)
}

