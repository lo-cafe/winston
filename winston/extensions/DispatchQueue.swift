//
//  DispatchQueue.swift
//  winston
//
//  Created by Igor Marcossi on 24/10/23.
//
import Dispatch
import Foundation

private var debounceWorkItems = [AnyHashable: DispatchWorkItem]()
private var lastThrottleCallTimes = [AnyHashable: DispatchTime]()
private let nilContext: AnyHashable = UInt32.random(in: 0..<UInt32.max)

public extension DispatchQueue {

    enum Constants {
        public enum AmountFormatting {
            static let maxFractionDigits: UInt = 2
        }

        public enum Throttle {
            public static let defaultInterval: TimeInterval = 1
        }

        public enum Debounce {
            public static let defaultDelay: TimeInterval = 1
        }
    }

    /**
     - parameters:
     - delay: The delay of closure execution
     - context: The context in which the throttle should be executed
     - action: The closure to be executed

     Delays a closure execution and ensures no other executions are made during deadline
     */
    func debounce(
        delay: TimeInterval = Constants.Debounce.defaultDelay,
        context: AnyHashable? = nil,
        action: @escaping () -> Void
    ) {
        let worker = DispatchWorkItem {
            defer { debounceWorkItems.removeValue(forKey: context ?? nilContext) }
            action()
        }

        asyncAfter(deadline: .now() + delay, execute: worker)

        debounceWorkItems[context ?? nilContext]?.cancel()
        debounceWorkItems[context ?? nilContext] = worker
    }

    /**
     - parameters:
     - interval: The interval in which new calls will be ignored
     - context: The context in which the debounce should be executed
     - action: The closure to be executed

     Executes a closure and ensures no other executions will be made during the interval.
     */
    func throttle(
        interval: Double = Constants.Throttle.defaultInterval,
        context: AnyHashable? = nil,
        action: @escaping () -> Void
    ) {
        if let last = lastThrottleCallTimes[context ?? nilContext], last + interval > .now() {
            return
        }

        lastThrottleCallTimes[context ?? nilContext] = .now()
        async(execute: action)

        // Cleanup & release context
        debounce(delay: interval) {
            lastThrottleCallTimes.removeValue(forKey: context ?? nilContext)
        }
    }
}
