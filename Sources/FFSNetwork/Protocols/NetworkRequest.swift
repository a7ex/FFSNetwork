//
//  NetworkRequest.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
/// A simple request object
/// An object conforming to *NetworkRequest* can be used for untyped response requests
/// For a typed response use *TypedNetworkRequest*, which inherits from *NetworkRequest*
/// The standard *URLRequest* conforms also to *NetworkRequest*, so it can be used whereever *NetworkRequest*
public protocol NetworkRequest {
    var baseUrl: URL? { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var allHTTPHeaderFields: [String: String]? { get }
    var httpBody: Data? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
}

/// Allow URLRequest to be used as NetworkRequest by conforming to protocol
extension URLRequest: NetworkRequest {
    public var baseUrl: URL? {
        guard let url = url else {
            return nil
        }
        var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComps?.scheme = url.scheme
        urlComps?.host = url.host
        return urlComps?.url
    }
    
    public var method: HTTPMethod {
        return HTTPMethod(rawValue: httpMethod ?? "get") ?? .get
    }
    
    public var path: String {
        return url?.path ?? ""
    }
    
    public var queryItems: [URLQueryItem]? {
        guard let url = url else {
            return nil
        }
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return comps?.queryItems
    }
}


