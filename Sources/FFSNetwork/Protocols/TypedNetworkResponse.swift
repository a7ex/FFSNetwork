//
//  TypedNetworkResponse.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public protocol TypedNetworkResponse {
    associatedtype ResponseType
    var urlResponse: URLResponse? { get }
    init(data: Data?, urlResponse: URLResponse?, sentRequest: URLRequest) throws
}
