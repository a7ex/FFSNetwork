//
//  FetchTodosRequest.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
import FFSNetwork

struct FetchTodosRequest: TypedNetworkRequest {
    typealias ReturnType = FetchTodosResponse
    
    private var mutableHeaders: [String: String]
    
    var allHTTPHeaderFields: [String : String]? {
        guard !mutableHeaders.isEmpty else {
            return nil
        }
        return mutableHeaders
    }
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    
    let path = "/todos"
    let method: HTTPMethod = .get
    let queryItems: [URLQueryItem]? = nil
    let httpBody: Data? = nil
    
    // we let ServerConnection construct the url to the backend
    let baseUrl: URL? = nil
    
    let mapResponse: (Data?, URLResponse?, URLRequest) throws -> ReturnType = ReturnType.init
    
    init(headers: [String: String]? = RequestHeaderConstants.JSONApplicationHeader,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.mutableHeaders = headers ?? [String: String]()
        self.cachePolicy = cachePolicy
        self.timeoutInterval = TimeInterval(60)
    }
    
    public mutating func setValue(_ value: String?, forHTTPHeaderField field: String) {
        mutableHeaders[field] = value
    }
}
