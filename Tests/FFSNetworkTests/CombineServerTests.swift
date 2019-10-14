//
//  CombineServerTests.swift
//  
//
//  Created by Alex da Franca on 13.10.19.
//

import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import FFSNetwork

@available(OSX 10.15, iOS 13, *)
final class CombineServerTests: XCTestCase {
    
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
    
    func testSimpleStringRx() {
        let serverConfiguration = StagingConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration)
        
        let request = Request(path: "/", baseUrl: URL(string: "https://www.farbflash.de")!)
        
        // Create the Publisher
        let publisher = serverConnection.runStringTaskWith(request, encoding: .utf8)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
    }
    
    func testInvalidUrlFailure() {
        struct MockConfiguration: ServerConfiguring {
            var urlComponents: URLComponents {
                let urlComponents = URLComponents()
                return urlComponents
            }
        }
        let serverConfiguration = MockConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration)
        
        let request = Request(path: "")
        
        // Create the Publisher
        expectPreconditionFailure(expectedMessage: "Unable to create URLRequest from request:") {
            serverConnection.runStringTaskWith(request, encoding: .utf8)
        }
        
//        // Test the Publisher
//        let validTest = evalValidResponseTest(publisher: publisher)
//        wait(for: validTest.expectations, timeout: TimeInterval(60))
//        validTest.cancellable?.cancel()
    }
    
    func evalValidResponseTest<T:Publisher>(publisher: T?, file: StaticString = #file, line: UInt = #line) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher, file: file, line: line)
        
        let expectationFinished = expectation(description: "finished")
        let expectationReceive = expectation(description: "receiveValue")
        
        let cancellable = publisher?.sink (receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)", file: file, line: line)
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertNotNil(response, file: file, line: line)
//            print("--TEST FULFILLED--")
//            print(response)
//            print("------")
            expectationReceive.fulfill()
        })
        return (expectations: [expectationFinished, expectationReceive], cancellable: cancellable)
    }
    
    func evalInvalidResponseTest<T:Publisher>(publisher: T?, file: StaticString = #file, line: UInt = #line) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher, file: file, line: line)
        
        let expectationFinished = expectation(description: "finished")
        let expectationFailure = expectation(description: "failure")
        
        let cancellable = publisher?.sink (receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                XCTAssertNotNil(error, file: file, line: line)
//                print("--TEST FULFILLED--")
//                print(error.localizedDescription)
//                print("------")
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
//                XCTFail("This is not the expected error", file: file, line: line)
            }
        }, receiveValue: { response in
            XCTAssertNil(response, file: file, line: line)
        })
        return (expectations: [expectationFailure, expectationFinished], cancellable: cancellable)
    }
    
}
