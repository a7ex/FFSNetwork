//
//  URLProtocolMock.swift
//
//  Created by Alex da Franca on 12.01.20.
//

import Foundation

/// Mock URLSession Responses
/// USAGE:
/// ```
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [URLProtocolMock.self]
/// let session = URLSession(configuration: config)
/// ```
/// This will return whatever is defined for that URL in URLProtocolMock.testURLs[request.url]
/// and the response defined in URLProtocolMock.response
/// and the error defined in URLProtocolMock.error
///
///References:
///  --: https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
///  --: https://nshipster.com/nsurlprotocol/
///
@objc class URLProtocolMock: URLProtocol {
    // this dictionary maps URLs to test data
    static var testURLs = [URL?: Data]()
    static var response: URLResponse?
    static var error: Error?
    
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
        // if we have a valid URL…
        if let url = request.url {
            // …and if we have test data for that URL…
            if let data = URLProtocolMock.testURLs[url] {
                // …load it immediately.
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        
        // …and we return our response if defined…
        if let response = URLProtocolMock.response {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        
        // …and we return our error if defined…
        if let error = URLProtocolMock.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        // mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // this method is required but doesn't need to do anything
    override func stopLoading() {
    }
}
