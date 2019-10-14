//
//  Request.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 14.10.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A concrete implementation of a NetworkRequest for convenience
public struct Request: NetworkRequest {
    public let baseUrl: URL?
    public let method: HTTPMethod
    public let path: String
    public let queryItems: [URLQueryItem]?
    public let allHTTPHeaderFields: [String : String]?
    public let httpBody: Data?
    public let cachePolicy: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
    
    public init(path: String,
         method: HTTPMethod = .get,
         allHTTPHeaderFields: [String : String]? = nil,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = TimeInterval(60),
         queryItems: [URLQueryItem]? = nil,
         httpBody: Data? = nil,
         baseUrl: URL? = nil
         ) {
        self.path = path
        self.method = method
        self.allHTTPHeaderFields = allHTTPHeaderFields
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.queryItems = queryItems
        self.httpBody = httpBody
        self.baseUrl = baseUrl
    }
}
