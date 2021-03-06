//
//  IntegrationTests.swift
//  
//
//  Created by Alex da Franca on 13.10.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSNetwork

class IntegrationTests: XCTestCase {
    func testSimpleHtmlResponse() {
        let urlSession = URLSession(configuration: .default)
        let serverConnection = ServerConnection(configuration: StagingConfiguration(), urlSession: urlSession) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        let request = URLRequest(url: URL(string: "https://www.farbflash.de")!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
        let expectation = self.expectation(description: "Simple html request")
        serverConnection.sendRequest(request) { (data, response, error) in
            XCTAssertNil(error)
            if let data = data {
            XCTAssertNotNil(String(data: data, encoding: .utf8))
            } else {
                XCTFail("There should be data")
            }
            XCTAssertNotNil(response)
            if let httpResponse = response as? HTTPURLResponse {
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertEqual((httpResponse.allHeaderFields["Content-Type"] as? String), "text/html")
            } else {
                XCTFail("There should be a http response")
            }
            
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTypedResponse() {
        let urlSession = URLSession(configuration: .default)
        let serverConnection = ServerConnection(configuration: StagingConfiguration(), urlSession: urlSession) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        let request = TypedRequest<StringResponse>(baseUrl: URL(string: "http://www.farbflash.de")!)
        let expectation = self.expectation(description: "Typed html request")
        serverConnection.runTaskWith(request) { (result: Result<StringResponse, Error>) in
            switch result {
            case .success(let stringResponse):
                XCTAssertEqual(stringResponse.sentRequest.url?.absoluteString, "http://www.farbflash.de/")
            
                XCTAssertGreaterThan(stringResponse.value.count, 0)
                XCTAssertTrue(stringResponse.value.contains("<title>Farbflash Home</title>"))
                
                if let httpResponse = stringResponse.urlResponse as? HTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200)
                XCTAssertEqual((httpResponse.allHeaderFields["Content-Type"] as? String), "text/html")
                } else {
                               XCTFail("There should be a http response")
                           }
                
            case .failure(let error):
                XCTFail("Received error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testJSONResponse() {
        let urlSession = URLSession(configuration: .default)
        let serverConnection = ServerConnection(configuration: StagingConfiguration(), urlSession: urlSession) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        let request = FetchTodosRequest()
        let expectation = self.expectation(description: "JSON request")
        serverConnection.sendNetworkRequest(request) { (data, response, error) in
            XCTAssertNil(error)
            if let data = data {
            XCTAssertNotNil(String(data: data, encoding: .utf8))
            } else {
                XCTFail("There should be data")
            }
            XCTAssertNotNil(response)
            if let httpResponse = response as? HTTPURLResponse {
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertEqual((httpResponse.allHeaderFields["Content-Type"] as? String), "application/json; charset=utf-8")
            } else {
                XCTFail("There should be a http response")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTypedJSONResponse() {
        let urlSession = URLSession(configuration: .default)
        let serverConnection = ServerConnection(configuration: StagingConfiguration(), urlSession: urlSession) { debugMessage, elapsedTime in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
        let request = FetchTodosRequest()
        
        let expectation = self.expectation(description: "Typed JSON request")
        serverConnection.runTaskWith(request) { (result: Result<FetchTodosResponse, Error>) in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.sentRequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/todos")
                XCTAssertEqual(todos.sentRequest.allHTTPHeaderFields?["Accept"], "application/json")
            
                XCTAssertGreaterThan(todos.value.count, 0)
                
                let httpResponse = todos.urlResponse as! HTTPURLResponse
                XCTAssertEqual(httpResponse.statusCode, 200)
                XCTAssertEqual((httpResponse.allHeaderFields["Content-Type"] as? String), "application/json; charset=utf-8")
                
            case .failure(let error):
                XCTFail("Received error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
}
