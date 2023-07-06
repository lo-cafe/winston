//
//  cancelableTimer.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import Foundation

struct TimerCancellable {
    let timer: Timer
    
    func cancel() {
        timer.invalidate()
    }
}

func cancelableTimer(_ seconds: TimeInterval, action: @escaping () -> Void) -> TimerCancellable {
    let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
        action()
    }
    return TimerCancellable(timer: timer)
}
