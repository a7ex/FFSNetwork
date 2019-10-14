//
//  Request.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 14.10.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A concrete implementation of a NetworkRequest for convenience
struct Request: NetworkRequest {
    let baseUrl: URL?
    let method: HTTPMethod
    let path: String
    let queryItems: [URLQueryItem]?
    let allHTTPHeaderFields: [String : String]?
    let httpBody: Data?
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    
    init(path: String,
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
