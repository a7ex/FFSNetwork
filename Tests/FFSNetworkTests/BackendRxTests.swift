//
//  BackendRxTests.swift
//  
//
//  Created by Alex da Franca on 14.10.19.
//

import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import FFSNetwork

@available(OSX 10.15, iOS 13, *)
class BackendRxTests: CombineServerTests {
    
    func testTodosRx() {
        let backend = BackendRx()
        
        // Create the Publisher
        let publisher = backend.loadTodosRx()
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
    }
    
    func testTodosRx2() {
        let backend = BackendRx()
        
        // Create the Publisher
        let publisher = backend.loadTodosRx2()
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
    }
}
