//
//  ServerConfiguring.swift
//  NetworkModul
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Deutsch Post E-Post GmbH. All rights reserved.
//

import Foundation

public protocol ServerConfiguring {
    var urlComponents: URLComponents { get }
}

public extension ServerConfiguring {
    func createURLRequest<T: NetworkRequest>(with request: T) throws -> URLRequest {
        var urlComps = URLComponents()
        
        // if request.baseUrl?.scheme is missing we use the scheme from the ServerConfiguration:
        urlComps.scheme = request.baseUrl?.scheme ?? urlComponents.scheme
        
        // if request.baseUrl?.host is missing we use the host from the ServerConfiguration:
        urlComps.host = request.baseUrl?.host ?? urlComponents.host
        
        urlComps.path = request.path
        urlComps.queryItems = request.queryItems
        if let url = urlComps.url {
            return URLRequest(url: url, requestLike: request)
        } else {
            throw ServerConnectionError.unableToCreateURLFromComponents(urlComps)
        }
    }
}

private extension URLRequest {
    init<T: NetworkRequest>(url requestUrl: URL, requestLike: T) {
        self.init(url: requestUrl)
        allHTTPHeaderFields = requestLike.allHTTPHeaderFields
        httpBody = requestLike.httpBody
        httpMethod = requestLike.method.rawValue
        cachePolicy = requestLike.cachePolicy
    }
}
