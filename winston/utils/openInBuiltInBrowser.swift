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
	if url.scheme?.lowercased().contains(/http(s)?/) == true {
		let vc = SFSafariViewController(url: url)
		UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
	} else {
		 UIApplication.shared.open(url)
	}
}


func openInBuiltInBrowser(_ urlStr: String) {
	if let url = URL(string: urlStr)  {
		if url.scheme?.lowercased().contains(/http(s)?/) == true {
			let vc = SFSafariViewController(url: url)
			UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
		} else {
			UIApplication.shared.open(url)
	  }
	}
}
