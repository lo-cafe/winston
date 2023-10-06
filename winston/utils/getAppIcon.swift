//
//  getAppIcon.swift
//  winston
//
//  Created by Igor Marcossi on 30/09/23.
//

import Foundation
import UIKit

func getAppIcon() -> UIImage {
   var appIcon: UIImage! {
     guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
     let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
     let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
     let lastIcon = iconFiles.last else { return nil }
     return UIImage(named: lastIcon)
   }
  return appIcon
}
