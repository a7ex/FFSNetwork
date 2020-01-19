//
//  Mocks.swift
//  
//
//  Created by Alex da Franca on 11.08.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import XCTest
@testable import FFSNetwork

struct Mocks {
    
    static let mockScheme = "https"
    static let mockBasehost = "jsonplaceholder.typicode.com"
    
    static var mockUrlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = mockScheme
        urlComponents.host = mockBasehost
        return urlComponents
    }
    
    static func mockedSessionServerReturning(data: Data?, response: HTTPURLResponse?, error: Error?, url: URL) -> ServerConnection {
        let serverConfiguration = Mocks.ServerConfigurationMock()
        let sessionMock = Mocks.MockedURLSession(
            mockURLSessionDataTask: Mocks.MockedURLSessionDataTask(
                expectedData: data,
                expectedResponse: response,
                expectedError: error
            )
        )
        return ServerConnection(configuration: serverConfiguration, urlSession: sessionMock)
    }
    
    static func mockedRequestServerReturning(data: Data?, response: HTTPURLResponse?, error: Error?, url: URL, file: StaticString = #file, line: UInt = #line) -> ServerConnection {
        let serverConfiguration = Mocks.ServerConfigurationMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let sessionMock = URLSession(configuration: config)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(url, request.url, file: file, line: line)
            if let error = error {
                throw error
            }
            return (response ?? HTTPURLResponse(), data ?? Data())
        }
        
        return ServerConnection(configuration: serverConfiguration, urlSession: sessionMock)
    }
    
    static func mockedURLServerReturning(data: Data?, response: HTTPURLResponse?, error: Error?, url: URL) -> ServerConnection {
        let serverConfiguration = Mocks.ServerConfigurationMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let sessionMock = URLSession(configuration: config)
        if let expectedData = data {
            URLProtocolMock.testURLs = [url: expectedData]
        } else {
            URLProtocolMock.testURLs = [URL: Data]()
        }
        URLProtocolMock.response = response
        URLProtocolMock.error = error
        
        return ServerConnection(configuration: serverConfiguration, urlSession: sessionMock)
    }
    
    struct ServerConfigurationMock: ServerConfiguring {
        var urlComponents: URLComponents {
            return mockUrlComponents
        }
    }
}

extension URLResponse {
    func corresponds(to rhs: HTTPURLResponse) -> Bool {
        guard let lhs = self as? HTTPURLResponse else {
            return false
        }
        return lhs.url?.absoluteString == rhs.url?.absoluteString &&
        lhs.mimeType == rhs.mimeType &&
        lhs.expectedContentLength == rhs.expectedContentLength &&
        lhs.textEncodingName == rhs.textEncodingName
    }
}

@available(OSX 10.15, iOS 13.0, *)
extension Mocks {
    static func mockedCombineServerReturning(data: Data?, response: HTTPURLResponse?, error: Error?, url: URL, file: StaticString = #file, line: UInt = #line) -> CombineServer {
        let serverConfiguration = Mocks.ServerConfigurationMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let sessionMock = URLSession(configuration: config)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(url, request.url, file: file, line: line)
            if let error = error {
                throw error
            }
            return (response ?? HTTPURLResponse(), data ?? Data())
        }
        
        return CombineServer(configuration: serverConfiguration, urlSession: sessionMock) { (debugMessage, elapsedTime) in
            if elapsedTime > 0 {
                let fileurl = URL(fileURLWithPath: #file)
                print("ELAPSED TIME: \(String(format: "%.04f", elapsedTime)) seconds (\(fileurl.lastPathComponent):\(#line))")
            }
            print(debugMessage)
        }
    }
}
