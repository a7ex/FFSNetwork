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
    
    // Requires online connection to succeed
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
        let publisher: AnyPublisher<FetchTodosResponse, ServerConnectionError> = serverConnection.runTypedTaskWith(FetchTodosRequest())
        
        // Test the Publisher
        let expectationFinished = expectation(description: "finished")
        let cancellable = publisher
            .sink (receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(ErrorMessageProvider.errorMessageFor(error))")
                    expectationFinished.fulfill()
                case .finished:
                    expectationFinished.fulfill()
                }
            }, receiveValue: { response in
                XCTAssertNotNil(response.value.first)
            })
        
        wait(for: [expectationFinished], timeout: TimeInterval(5))
        cancellable.cancel()
    }
    
    // Requires online connection to succeed
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
        let request = Request(path: "/todos", cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
        let publisher: AnyPublisher<[Todo], ServerConnectionError> = serverConnection.runJSONTaskWith(request)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
    
    // Requires online connection to succeed
    func testSimpleStringRx() {
        let serverConfiguration = StagingConfiguration()
        let serverConnection = CombineServer(configuration: serverConfiguration) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        
        let request = Request(path: "/", cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, baseUrl: URL(string: "https://www.farbflash.de")!)
        
        // Create the Publisher
        let publisher = serverConnection.runStringTaskWith(request, encoding: .utf8)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
}

@available(OSX 10.15, iOS 13, *)
extension XCTestCase {
    func evalValidResponseTest<T:Publisher>(publisher: T?, file: StaticString = #file, line: UInt = #line, evaluation: @escaping ((Any) -> Void) = { _ in }) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher, file: file, line: line)
        
        let expectationFinished = expectation(description: "finished")
        
        let cancellable = publisher?.sink (receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                if let serverError = error as? ServerConnectionError {
                    XCTFail("Error: \(ErrorMessageProvider.errorMessageFor(serverError))", file: file, line: line)
                } else {
                    XCTFail("Error: \(error.localizedDescription)", file: file, line: line)
                }
                expectationFinished.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            evaluation(response)
        })
        return (expectations: [expectationFinished], cancellable: cancellable)
    }
    
    func evalInvalidResponseTest<T:Publisher>(publisher: T?, file: StaticString = #file, line: UInt = #line) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher, file: file, line: line)
        
        let expectationFinished = expectation(description: "finished")
        
        let cancellable = publisher?.sink (receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                XCTAssertNotNil(error, file: file, line: line)
                expectationFinished.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertNil(response, file: file, line: line)
        })
        return (expectations: [expectationFinished], cancellable: cancellable)
    }
}
