//
//  TypedNetworkResponse.swift
//  NetworkModul
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Deutsch Post E-Post GmbH. All rights reserved.
//

import Foundation

public protocol TypedNetworkResponse {
    associatedtype ResponseType
    var urlResponse: URLResponse? { get }
    init(data: Data?, urlResponse: URLResponse?, sentRequest: URLRequest) throws
}
