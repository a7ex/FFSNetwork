//
//  File.swift
//  
//
//  Created by Alex da Franca on 11.08.19.
//

import Foundation
@testable import FFSNetwork

struct MockData {
    struct URLSessionMock: DataTaskCreator {
        let mockURLSessionDataTask: MockURLSessionDataTask
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            mockURLSessionDataTask.completionHandler = completionHandler
            return mockURLSessionDataTask
        }
    }
    
    class MockURLSessionDataTask: URLSessionDataTask {
        let expectedData: Data?
        let expectedResponse: URLResponse?
        let expectedError: Error?
        var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
        
        init(expectedData: Data?,
            expectedResponse: URLResponse?,
            expectedError: Error?,
            completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
            self.expectedData = expectedData
            self.expectedResponse = expectedResponse
            self.expectedError = expectedError
            self.completionHandler = completionHandler
        }
        
        override func resume() {
            completionHandler?(expectedData, expectedResponse, expectedError)
        }
    }
    
    struct ServerConfigurationMock: ServerConfiguring {
        var urlComponents: URLComponents {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "jsonplaceholder.typicode.com"
            return urlComponents
        }
    }
}
