//
//  ProductionConfiguration.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
import FFSNetwork

struct ProductionConfiguration: ServerConfiguring {
    var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "production-api.example.com"
        return urlComponents
    }
}
