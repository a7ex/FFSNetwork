//
//  StagingConfiguration.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
import FFSNetwork

struct StagingConfiguration: ServerConfiguring {
    var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "jsonplaceholder.typicode.com"
        return urlComponents
    }
}
