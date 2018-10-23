//
//  Promise.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 7/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public typealias AnyPromise = Promise<Any>

open class Promise<Element> {
    public typealias Function = (_ result: @escaping Resolve) -> Void
    public typealias Resolve = (PromiseResult<Element>) -> Void
    
    var queue: DispatchQueue
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
    open func then<NextElement>(_ completion: @escaping (PromiseResult<Element>) -> PromiseResult<NextElement>) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { resolve(completion($0)) }
        }
    }
    
    @discardableResult
    open func then<NextElement>(_ completion: @escaping (PromiseResult<Element>, @escaping (PromiseResult<NextElement>) -> Void) -> Void) -> Promise<NextElement> {
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
    open func chain<NextElement>(_ chaining: @escaping (PromiseResult<Element>) -> Promise<NextElement>) -> Promise<NextElement> {
        return Promise<NextElement>(queue: queue) { (resolve) in
            self.execute { (result) in chaining(result).execute(resolve) }
        }
    }
    
    @discardableResult
    open func chain<NextElement>(_ chaining: @escaping (PromiseResult<Element>, _ completion: @escaping (Promise<NextElement>) -> Void) -> Void) -> Promise<NextElement> {
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

//MARK: - Combining
extension Promise {
    public static func combining<A, B>(queue: DispatchQueue = .main, promiseA: Promise<A>, promiseB: Promise<B>) -> Promise<(A, B)> {
        return Promise<(A, B)>(queue: queue) { (resolve) in
            var firstResult: PromiseResult<A>!
            var secondResult: PromiseResult<B>!
            
            let group = DispatchGroup()
            
            group.enter()
            promiseA.execute { (result) in
                firstResult = result
                group.leave()
            }
            
            group.enter()
            promiseB.execute { (result) in
                secondResult = result
                group.leave()
            }
            
            group.notify(queue: queue) {
                resolve(firstResult.combining(otherResult: secondResult))
            }
        }
    }
    
    public static func combining(queue: DispatchQueue = .main, promises: AnyPromise...) -> Promise<[Any]> {
        return Promise<[Any]>(queue: queue) { (resolve) in
            var results: [Int: PromiseResult<Any>] = [:]
            let group = DispatchGroup()
            
            promises.enumerated().forEach { (index, prom) in
                group.enter()
                prom.execute { (result) in
                    results[index] = result
                    group.leave()
                }
            }
            
            group.notify(queue: queue) {
                if let errorResult = results.values.first(where: { (result) -> Bool in
                    return result.maybeError != nil
                }) {
                    resolve(errorResult.catchMap { return [$0] })
                } else {
                    let elements = results.keys.sorted().compactMap { results[$0]?.unbox() }
                    resolve(.value(element: elements))
                }
            }
        }
    }
}

extension Promise {
    public var any: AnyPromise {
        return map { $0 as Any }
    }
    
    public func map<R>(_ transform: @escaping (Element) throws -> R) -> Promise<R> {
        return Promise<R>(queue: queue) { (resolve) in
            self.execute { resolve($0.catchMap(transform)) }
        }
    }
}
