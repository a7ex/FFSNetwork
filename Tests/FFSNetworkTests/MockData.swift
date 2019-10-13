//
//  MockData.swift
//  
//
//  Created by Alex da Franca on 11.08.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
@testable import FFSNetwork

struct MockData {
    static func serverConnectionWhichReturns(data: Data?, response: URLResponse?, error: Error?) -> ServerConnection {
        let serverConfiguration = MockData.ServerConfigurationMock()
        let sessionMock = MockData.URLSessionMock(
            mockURLSessionDataTask: MockData.MockURLSessionDataTask(
                expectedData: data,
                expectedResponse: response,
                expectedError: error
            )
        )
        return ServerConnection(configuration: serverConfiguration, urlSession: sessionMock)
    }
    
    private struct URLSessionMock: DataTaskCreator {
        let mockURLSessionDataTask: MockURLSessionDataTask
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            mockURLSessionDataTask.completionHandler = completionHandler
            return mockURLSessionDataTask
        }
    }
    
    private class MockURLSessionDataTask: URLSessionDataTask {
        let expectedData: Data?
        let expectedResponse: URLResponse?
        let expectedError: Error?
        var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
        
        init(expectedData: Data?,
            expectedResponse: URLResponse?,
            expectedError: Error?) {
            self.expectedData = expectedData
            self.expectedResponse = expectedResponse
            self.expectedError = expectedError
        }
        
        override func resume() {
            completionHandler?(expectedData, expectedResponse, expectedError)
        }
    }
    
    private struct ServerConfigurationMock: ServerConfiguring {
        var urlComponents: URLComponents {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "jsonplaceholder.typicode.com"
            return urlComponents
        }
    }
}
