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
class BackendRxTests: XCTestCase {
    
    // Requires online connection to succeed
    func testTodosRxWithTodoRequest() {
        let backend = BackendCombine() // Server with StagingConfiguration(): "https://jsonplaceholder.typicode.com"
        
        // Create the Publisher
        let publisher = backend.loadTodosAsTodoResponse() // "https://jsonplaceholder.typicode.com/todos"
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
    
    // Requires online connection to succeed
    func testTodosRxWithTypedRequest() {
        let backend = BackendCombine() // Server with StagingConfiguration(): "https://jsonplaceholder.typicode.com"
        
        // Create the Publisher
        let publisher = backend.loadTodosAsJSONRequest() // "https://jsonplaceholder.typicode.com/todos"
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
}
