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
        let publisher: AnyPublisher<FetchTodosResponse, ServerConnectionError> = serverConnection.runTypedTaskWith(FetchTodosRequest())
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
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
        let publisher: AnyPublisher<[Todo], ServerConnectionError> = serverConnection.runJSONTaskWith(request)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: TimeInterval(5))
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
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
    
    func testMockedCombineNetworkCall() {
        let typedRequest = TypedRequest<StringResponse>()
        let expectedValue = ["key": "value"]
        
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        
        let expectedData = try! JSONEncoder().encode(expectedValue)
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let serverConnection = Mocks.mockedCombineServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        let publisher: AnyPublisher<[String: String], ServerConnectionError> = serverConnection.runJSONTaskWith(URLRequest(url: url))
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher) { value in
            if let dict = value as? [String: String] {
                XCTAssertEqual(dict["key"], expectedValue["key"])
            } else {
                XCTFail("Expected value")
            }
        }
        wait(for: validTest.expectations, timeout: TimeInterval(5))
        validTest.cancellable?.cancel()
    }
    
    func testMockedCombineTypedNetworkCall() {
        let typedRequest = FetchTodosRequest()
        
        let expectedString = "[{\"userId\": 1, \"id\": 1, \"title\": \"Todo title\", \"completed\": true}]"
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let serverConnection = Mocks.mockedCombineServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        let publisher: AnyPublisher<FetchTodosResponse, ServerConnectionError> = serverConnection.runTypedTaskWith(typedRequest)
        
        // Test the Publisher
        let validTest = evalValidResponseTest(publisher: publisher) { value in
            if let response = value as? FetchTodosResponse {
                let todos = response.value
                if let todo = todos.first {
                    XCTAssertEqual(todo.title, "Todo title")
                    XCTAssertEqual(todo.id, 1)
                    XCTAssertEqual(todo.userId, 1)
                    XCTAssertEqual(todo.completed, true)
                } else {
                    XCTFail("Expected one element")
                }
            } else {
                XCTFail("Expected value")
            }
        }
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
