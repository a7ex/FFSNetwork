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
class CombineServerTests: XCTestCase {
    
    func testTodosRxTypedNetworkRequest() {
        let serverConfiguration = StagingConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        
        // Create the Publisher
        let publisher: AnyPublisher<FetchTodosResponse, Error> = serverConnection.runTaskWith(FetchTodosRequest())
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
    }
    
    func testTodosRxUsingJSONTask() {
        let serverConfiguration = StagingConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        
        // Create the Publisher
        let request = Request(path: "/todos")
        let publisher: AnyPublisher<[Todo], Error> = serverConnection.runJSONTaskWith(request)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
    }
    
    func testSimpleStringRx() {
        let serverConfiguration = StagingConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        
        let request = Request(path: "/", baseUrl: URL(string: "https://www.farbflash.de")!)
        
        // Create the Publisher
        let publisher = serverConnection.runStringTaskWith(request, encoding: .utf8)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(60))
        validTest.cancellable?.cancel()
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
