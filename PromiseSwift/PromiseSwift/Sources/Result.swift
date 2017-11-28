//
//  Result.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 7/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public enum Result<T> {
    case value(element: T)
    case error(error: Error)
}

extension Result {
    public func unbox() -> T? {
        switch self {
        case let .value(element):
            return element
        default:
            return nil
        }
    }
    
    public func map<U>(_ lambda: (_ transform: T) throws -> U) rethrows -> Result<U> {
        switch self {
        case let .value(element):
            return .value(element: try lambda(element))
        case let .error(error):
            return .error(error: error)
        }
    }
    
    public func catchMap<U>(_ lambda: (_ transform: T) throws -> U) -> Result<U> {
        switch self {
        case let .value(element):
            do {
                return .value(element: try lambda(element))
            } catch {
                return .error(error: error)
            }
        case let .error(error):
            return .error(error: error)
        }
    }
}

public func flatten<T>(_ result: Result<Result<T>>) -> Result<T> {
    switch result {
    case let .value(element):
        return element
    case let .error(error):
        return .error(error: error)
    }
}

