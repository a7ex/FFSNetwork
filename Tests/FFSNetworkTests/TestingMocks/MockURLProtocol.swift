//
//  MockURLProtocol.swift
//  
//
//  Created by Alex da Franca on 18.01.20.
//

import XCTest

enum MockURLProtocolError: Error {
    case errorWithResponse(response: HTTPURLResponse, error: Error)
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Wrong test setup: Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            if case let MockURLProtocolError.errorWithResponse(response, unwrappedError) = error {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didFailWithError: unwrappedError)
            } else {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }
    
    // this method is required but doesn't need to do anything
    override func stopLoading() {
    }
}
