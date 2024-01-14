//
//  Scacity.swift
//  winston
//
//  Created by Igor Marcossi on 16/12/23.
//

import SwiftUI

extension AnyTransition {
  public static var scacity: AnyTransition = .scale.combined(with: .opacity)
}
