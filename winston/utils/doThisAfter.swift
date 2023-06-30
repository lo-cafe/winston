//
//  doThisAfter.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation

func doThisAfter(_ seconds: CGFloat, callback: @escaping () -> Void) {
    return DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        callback()
    }
}
