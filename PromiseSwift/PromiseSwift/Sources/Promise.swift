//
//  Promise.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 7/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

open class Promise<Element> {
    public typealias Function = (_ result: @escaping Resolve) -> Void
    public typealias Resolve = (Result<Element>) -> Void
    
    fileprivate var queue: DispatchQueue
    fileprivate var function: Function
    
    public init(queue: DispatchQueue = .main, _ function: @escaping Function) {
        self.queue = queue
        self.function = function
    }
    
    public init(queue: DispatchQueue = .main, _ element: Element) {
        self.queue = queue
        self.function = { $0(.value(element: element)) }
    }
    
    @discardableResult
    open func then<NextElement>(_ completion: @escaping (Result<Element>) -> Result<NextElement>) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { resolve(completion($0)) }
        }
    }
    
    @discardableResult
    open func then<NextElement>(_ completion: @escaping (Result<Element>, @escaping (Result<NextElement>) -> Void) -> Void) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { (result) in completion(result, { resolve($0) }) }
        }
    }
    
    @discardableResult
    open func after(_ call: @escaping () -> Void) -> Promise<Element> {
        return Promise(queue: queue) { (resolve) in
            self.execute { (result) in
                call()
                resolve(result)
            }
        }
    }
    
    @discardableResult
    open func chain<NextElement>(_ chaining: @escaping (Result<Element>) -> Promise<NextElement>) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { (result) in chaining(result).execute(resolve) }
        }
    }
    
    @discardableResult
    open func chain<NextElement>(_ chaining: @escaping (Result<Element>, _ completion: @escaping (Promise<NextElement>) -> Void) -> Void) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { (result) in
                chaining(result) { $0.execute(resolve) }
            }
        }
    }
    
    @discardableResult
    open func `catch`(shouldContinue: Bool = true, _ handler: @escaping (_ error: Error) -> Void) -> Promise<Element> {
        return Promise<Element>(queue: queue) { (resolve) in
            self.execute { (result) in
                
                switch result {
                case let .error(error): handler(error)
                default: break
                }
                
                if shouldContinue {
                    resolve(result)
                }
            }
        }
    }
    
    open func execute(_ completion: Resolve? = nil) {
        let completion = completion ?? {_ in }
        queue.async {
            self.function(completion)
        }
    }
}

