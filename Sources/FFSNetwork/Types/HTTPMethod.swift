//
//  HTTPMethod.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// Use an enum rather than string for the HTTP method
public enum HTTPMethod: String {
    case get, post, put, delete, patch
}
