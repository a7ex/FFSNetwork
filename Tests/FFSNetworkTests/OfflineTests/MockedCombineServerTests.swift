//
//  MockedCombineServerTests.swift
//  
//
//  Created by Alex da Franca on 19.01.20.
//

import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import FFSNetwork

@available(OSX 10.15, iOS 13, *)
class MockedCombineServerTests: XCTestCase {
    
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
