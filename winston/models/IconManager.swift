//
//  IconManager.swift
//  winston
//
//  Created by Igor Marcossi on 30/09/23.
//

import Foundation
import SwiftUI

enum WinstonAppIcon: String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  
  case standard,
       explode,
       peak,
       side,
       simpleEyesBlack,
       simpleEyesBlue,
       simpleFaceBlack,
       simpleFaceBlue
  
  var description: String {
    switch self {
    case .standard: return "Classic winston icon"
    case .explode: return "One of Winstin's heroic moments."
    case .peak: return "Really, anyone?"
    case .side: return "Wow, look at him!"
    case .simpleEyesBlack: return "Why not right?"
    case .simpleEyesBlue: return "Why not in blue this time."
    case .simpleFaceBlack: return "Ok, I'll add the whole face."
    case .simpleFaceBlue: return "Ok... Blue..."
    }
  }
  
  var label: String {
    switch self {
    case .standard: return "Default"
    case .explode: return "Fantastic!"
    case .peak: return "Anyone?"
    case .side: return "Side view"
    case .simpleEyesBlack: return "Eyes (Black)"
    case .simpleEyesBlue: return "Eyes (Blue)"
    case .simpleFaceBlack: return "Face (Black)"
    case .simpleFaceBlue: return "Face (Blue)"
    }
  }
  
  var name: String? {
    switch self {
    case .standard: return nil
    case .explode: return "iconExplode"
    case .peak: return "iconPeak"
    case .side: return "iconSide"
    case .simpleEyesBlack: return "iconSimpleEyesBlack"
    case .simpleEyesBlue: return "iconSimpleEyesBlue"
    case .simpleFaceBlack: return "iconSimpleFaceBlack"
    case .simpleFaceBlue: return "iconSimpleFaceBlue"
    }
  }
  
  var preview: UIImage { UIImage(named: self.name ?? "iconStandard")! }
}

class AppIconManger {
  var current: WinstonAppIcon {
    return WinstonAppIcon.allCases.first(where: {
      $0.name == UIApplication.shared.alternateIconName
    }) ?? .standard
  }
  
  func setIcon(_ appIcon: WinstonAppIcon, completion: ((Bool) -> Void)? = nil) {
    guard current != appIcon,
          UIApplication.shared.supportsAlternateIcons
    else { return }
    UIApplication.shared.setAlternateIconName(appIcon.name) { error in
      if let error = error {
        print("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)")
      }
      completion?(error != nil)
    }
  }
}
