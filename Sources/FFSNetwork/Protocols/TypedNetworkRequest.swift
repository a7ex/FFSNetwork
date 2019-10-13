//
//  TypedNetworkRequest.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A specialized version of NetworkRequest, which can transform the retrieved data to a defined type
/// Allowing type safe result values
public protocol TypedNetworkRequest: NetworkRequest {
    associatedtype ReturnType: TypedNetworkResponse
    
    /// Create an instance of ReturnType from the network response
    /// if it succeeds, we get the expected value in the instance of ReturnType,
    /// otherwise we catch the error, which occurred during the entire
    /// process of loading and parsing the remote resource.
    var mapResponse: (Data?, URLResponse?, URLRequest) throws -> ReturnType { get }
}
