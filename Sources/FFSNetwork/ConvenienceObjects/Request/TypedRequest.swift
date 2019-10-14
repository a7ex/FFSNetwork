//
//  BackendRequest.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 25.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A basic implementation of a TypedNetworkRequest type
/// Defines all required properties for a request in initializer by providing default values
public struct TypedRequest<T: TypedNetworkResponse>: TypedNetworkRequest {
    public typealias ReturnType = T
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public var allHTTPHeaderFields: [String : String]? {
        guard !mutableHeaders.isEmpty else {
            return nil
        }
        return mutableHeaders
    }
    public let cachePolicy: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
    public let httpBody: Data?
    public var mapResponse: (Data?, URLResponse?, URLRequest) throws -> ReturnType = ReturnType.init
    
    // We let ServerConnection construct the url to the backend
    // if baseUrl is nil, ServerConnection will use its own baseUrl
    public let baseUrl: URL?
    
    private var mutableHeaders: [String: String]
    
    public init(path: String = "/",
         method: HTTPMethod = .get,
         headers: [String: String]? = nil,
         queryItems: [URLQueryItem]? = nil,
         httpBody: Data? = nil,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
          timeoutInterval: TimeInterval = TimeInterval(60),
         baseUrl: URL? = nil) {
        self.path = path
        self.method = method
        self.mutableHeaders = headers ?? [String: String]()
        self.queryItems = queryItems
        self.httpBody = httpBody
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.baseUrl = baseUrl
    }
    
    /// this is actually the conformance to AuthSession.CanSetHeaderValues protocol
    /// so that this template can be used in AuthSession.Authenticator.authenticateRequest()
    /// all you need to do in your code is:
    /// ```
    /// import AuthSession
    /// extension BackendRequest: CanSetHeaderValues { }
    ///```
    public mutating func setValue(_ value: String?, forHTTPHeaderField field: String) {
        mutableHeaders[field] = value
    }
}
