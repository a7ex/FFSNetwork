//
//  NetworkResultData.swift
//  NetworkStack
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct NetworkResultData {
    public let data: Data?
    public let response: URLResponse?
    public let error: Error?
}
