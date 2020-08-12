//
//  RetryAction.swift
//  BaseNetworking
//
//  Created by Nguyen Vu Hao on 8/5/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public typealias RetryActionBlock = (_ retry: RetryAction) -> Void
public typealias RetryActionInvalidBlock = (_ retry: RetryAction, _ invalidType: RetryAction.InvalidType) -> ()

/// RetryAction support for retrying task with strategy(Interval|Leap)
open class RetryAction {

    /// The RetryType strategy type.
    /// Interval(interval, numberOfMaxRetry) that support to retry a task after interval and maxCount.
    /// Leap(esplase, maximumInterval, numberOfMaxRetry) that support to retry a task in linear time increase by
    /// Multiple the esplase and barriered by maximumInterval, numberOfMaxRetry.
    /// Ex: Leap(2, 32, 7) => 2, 4, 8, 16, 32, 32 ,32, stop
    public enum RetryType {
        case interval(interval: TimeInterval, numberOfMaxRetry: UInt)
        case leap(esplase: UInt, maximumInterval: UInt, numberOfMaxRetry: UInt)
    }

    /// The stopped invalid type of RetryAction.
    /// interactive (outside manually call stop)
    /// reachedMaxNumberOfRetry the retry action reached the max count
    /// deinit The RtryAction object deinit
    public enum InvalidType {
        case interactive
        case reachedMaxNumberOfRetry
        case `deinit`
    }

    /// The state of instance RetryAction
    public enum State {
        case idle
        case running
        case stopped
    }

    /// The type strategy of RetryAction
    public let type: RetryType

    /// The current running state
    public private(set) var state: State = .idle

    /// The action block to callback execute the task retry
    public let actionBlock: RetryActionBlock

    /// The invalid block invoked when the retry task finised
    public let invalidBlock: RetryActionInvalidBlock?

    private lazy var timer: SafeTimer = {
        let timer = SafeTimer()
        timer.delegate = self
        return timer
    }()

    public private(set) var numberOfRetry: UInt = 0

    private init(type: RetryType,
                 actionBlock: @escaping RetryActionBlock,
                 invalidBlock: RetryActionInvalidBlock?)
    {
        self.type = type
        self.actionBlock = actionBlock
        self.invalidBlock = invalidBlock
    }

    deinit {
        self.stop(with: .deinit)
    }

    /// Intialize the RetryAction object.
    /// You should keep this instance to make sure it working without released while doing it's job
    /// - Parameter type: The RetryAction Strategy
    /// - Parameter actionBlock: The callback of task need to retry and handle
    /// - Parameter invalidBlock: The invalid block invoked when the retry task finised
    public static func create(type: RetryType,
                              actionBlock: @escaping RetryActionBlock,
                              invalidBlock: RetryActionInvalidBlock? = nil) -> RetryAction
    {
        let retry = RetryAction(type: type, actionBlock: actionBlock, invalidBlock: invalidBlock)
        return retry
    }

    /// Start the action to execute code in actionBlock and schedule timer
    open func start() {
        guard state == .idle else {
            assertionFailure("The RetryAction is running or stopped")
            return
        }

        self.state = .running
        self.actionBlock(self)
    }

    /// Call this function in actionBlock when you need you task retry on the setup strategy
    open func retry() {
        switch self.type {
        case .interval(let interval, let numberOfMaxRetry):
            self.numberOfRetry += 1
            if self.numberOfRetry < numberOfMaxRetry {
                self.timer.schedule(timeInterval: interval, repeats: false, userInfo: nil)
            } else {
                self.stop(with: .reachedMaxNumberOfRetry)
            }
        case .leap(let esplase, let maximumInterval, let numberOfMaxRetry):
            self.numberOfRetry += 1
            let nextDecimal = min(pow(Decimal(esplase), Int(self.numberOfRetry)), Decimal(maximumInterval))
            let nextInterval = TimeInterval(truncating: NSDecimalNumber(decimal: nextDecimal))

            if self.numberOfRetry < numberOfMaxRetry {
                self.timer.schedule(timeInterval: nextInterval, repeats: false, userInfo: nil)
            } else {
                self.stop(with: .reachedMaxNumberOfRetry)
            }
        }
    }

    /// Call this function in actionBlock when you need you task finish
    open func stop() {
        self.stop(with: .interactive)
    }

    private func stop(with invalidType: InvalidType) {
        if self.state == .stopped {
            return
        }
        self.timer.invalidate()
        self.invalidBlock?(self, invalidType)
        self.state = .stopped
    }

}

extension RetryAction: SafeTimerDelegate {
    public func safeTimerDidTrigger(_ safeTimer: SafeTimer) {
        self.actionBlock(self)
    }
}
