//
//  Promise.swift
//
//  Created by Nguyen Vu Hao on 8/5/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

typealias PromiseExcuteBlock = (PromiseResult) -> ()
typealias PromiseErrorBlock = (Error) -> ()
typealias PromiseFinishedBlock = () -> ()

class Promise {

    fileprivate var errorBlock: PromiseErrorBlock?
    fileprivate var finishBlock: PromiseFinishedBlock?

    fileprivate var isStarted: Bool = false
    fileprivate var isCanncelled: Bool = false
    fileprivate var excuteQueue: DispatchQueue = DispatchQueue(label: "com.PromiseQueue")
    fileprivate var onQueue: DispatchQueue
    fileprivate var excuteBlocks: [PromiseExcuteBlock] = []

    lazy private(set) var promiseResult: PromiseResult = {
        return PromiseResult(promise: self)
    }()

    init(onQueue: DispatchQueue = .main, block: PromiseExcuteBlock? = nil) {
        self.onQueue = onQueue

        if let block = block {
            self.excuteBlocks.append(block)
        }
    }

    func start() {
        if isStarted == true {
            return
        }

        isStarted = true
        self.excuteNextBlock()
    }

    fileprivate func excuteNextBlock() {
        self.onQueue.async { [weak self] in
            guard let `self` = self else {return}
            if let block = self.excuteBlocks.first {
                block(self.promiseResult)
                _ = self.excuteBlocks.removeFirst()
            } else {
                self.finishBlock?()
            }
        }
    }

    @discardableResult
    func then(_ thenBlock: @escaping PromiseExcuteBlock) -> Promise {
        self.excuteBlocks.append(thenBlock)
        return self
    }

    @discardableResult
    func error(_ errorBlock: @escaping PromiseErrorBlock) -> Promise {
        self.errorBlock = errorBlock
        return self
    }

    @discardableResult
    func finished(_ finishBlock: @escaping PromiseFinishedBlock) -> Promise  {
        self.finishBlock = finishBlock
        return self
    }
}

final class PromiseResult {

    private weak var promise: Promise?
    private(set) var currentValue: Any?

    init(promise: Promise) {
        self.promise = promise
    }

    func error(_ error: Error) {
        self.promise?.isCanncelled = true
        self.promise?.onQueue.async { [weak self] in
            guard let `self` = self else {return}
            self.promise?.errorBlock?(error)
        }
    }

    func finished() {
        self.promise?.isCanncelled = true
        self.promise?.onQueue.async { [weak self] in
            guard let `self` = self else {return}
            self.promise?.finishBlock?()
        }
    }

    func next(_ value: Any?) {
        self.currentValue = value
        self.promise?.excuteNextBlock()
    }
}
