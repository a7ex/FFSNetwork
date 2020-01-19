//
//  ServerConfiguring.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// Objects conforming to protocol *ServerConfiguring* can be used to configure a *ServerConnection*.
/// All it provides is an URLComponents object.
/// It provides a default implementation to create a regular *URLRequest" from any object, conforming to "NetworkRequest*
/// *ServerConfiguring* basically only provides the scheme and host of the server. However, if the request contains
/// a 'baseUrl' property, the scheme and host from that request.baseUrl are taken. In that case ServerConfiguring's urlComponents
/// are not used at all. Rather everything to construct the URLRequest is read from the parameter 'request', which
/// is an object conforming to *NetworkRequest*
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
        
        if let port = request.baseUrl?.port ?? urlComponents.port {
            urlComps.port = port
        }
        
        urlComps.path = request.path
        urlComps.queryItems = request.queryItems
        if let url = urlComps.url {
            if url.absoluteString.isEmpty {
                throw ServerConnectionError.unableToCreateURLFromComponents(urlComps)
            }
            return URLRequest(url: url,
                              requestLike: request,
                              cachePolicy: request.cachePolicy,
                              timeoutInterval: request.timeoutInterval)
        } else {
            throw ServerConnectionError.unableToCreateURLFromComponents(urlComps)
        }
    }
}

private extension URLRequest {
    init<T: NetworkRequest>(url requestUrl: URL,
                            requestLike: T,
                            cachePolicy: URLRequest.CachePolicy,
                            timeoutInterval: TimeInterval) {
        self.init(url: requestUrl, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        allHTTPHeaderFields = requestLike.allHTTPHeaderFields
        httpBody = requestLike.httpBody
        httpMethod = requestLike.method.rawValue
    }
}
