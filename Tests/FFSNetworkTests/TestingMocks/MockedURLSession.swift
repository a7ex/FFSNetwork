//
//  MockedURLSession.swift
//  
//
//  Created by Alex da Franca on 19.01.20.
//

import Foundation
@testable import FFSNetwork

extension Mocks {
    struct MockedURLSession: DataTaskCreator {
        let configuration = URLSessionConfiguration.default
        let mockURLSessionDataTask: MockedURLSessionDataTask
        
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            mockURLSessionDataTask.completionHandler = completionHandler
            return mockURLSessionDataTask
        }
    }
    
    class MockedURLSessionDataTask: URLSessionDataTask {
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
}
