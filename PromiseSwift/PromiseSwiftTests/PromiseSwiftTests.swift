//
//  PromiseSwiftTests.swift
//  PromiseSwiftTests
//
//  Created by Gleb Radchenko on 11/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import XCTest
@testable import PromiseSwift

class PromiseSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testError() {
        let exp = expectation(description: "\(#function)")
        
        Promise(1)
            .then { (result) -> Result<Int> in
                .error(error: CustomError.emptyError)
            }
            .catch { (error) in
                exp.fulfill()
            }
            .execute()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testValue() {
        let exp = expectation(description: "\(#function)")
        
        Promise(1)
            .then { (result) -> Result<Double> in
                result.map { Double($0) }
            }
            .then { (result) -> Result<Float> in
                result.map { Float($0) }
            }
            .execute { (result) in
                XCTAssertNotNil(result.unbox())
                exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testSimpleRequest() {
        let url = URL(string: "http://echo.jsontest.com/key/value/one/two")!
        let exp = expectation(description: "\(#function)")
        
        Network(url: url).post().execute { (result) in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    func testChaining() {
        let url = URL(string: "http://echo.jsontest.com/key/value/one/two")!
        let exp = expectation(description: "\(#function)")
        
        Network(url: url).post()
            .then { (result) -> Result<Any> in
                result.catchMap { try JSONSerialization.jsonObject(with: $0, options: .mutableLeaves) }
            }
            .then { (result) -> Result<[String: String]> in
                result.map { $0 as? [String: String] ?? [:] }
            }
            .chain { (result) -> Promise<[String: String]> in
                return Promise() { (resolve) in
                    resolve(result.map { $0 })
                }
            }
            .then { (result) -> Result<[String]> in
                return result.map { v in v.keys.map { $0 } }
            }
            .execute { (result) in
                exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
}

