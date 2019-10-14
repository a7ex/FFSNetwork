//
//  TypedNetworkResponse.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// An object conforming to *TypedNetworkResponse* is required for typed results
/// It must have a failable initializer, which takes 3 parameters:
/// optional data, optional URLResponse and the originating URLRequest
/// data and urlResponse come from the URLSession response, the request is sent along as a convenience
public protocol TypedNetworkResponse {
    associatedtype ResponseType
    var urlResponse: URLResponse? { get }
    init(data: Data?, urlResponse: URLResponse?, sentRequest: URLRequest) throws
}
