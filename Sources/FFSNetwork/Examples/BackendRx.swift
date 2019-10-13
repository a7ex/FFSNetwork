//
//  BackendRx.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 10.08.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
import FFSNetwork
#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13, *)
struct BackendRx {
    private let serverConnection: CombineServer
    
    init(_ serverConfiguration: ServerConfiguring = StagingConfiguration()) {
        serverConnection = CombineServer(configuration: serverConfiguration)
    }
}

extension BackendRx {
    func loadDefectsRx() -> AnyPublisher<[Defect], Error> {
        return serverConnection.runTaskWith(AllDefectsRequest())
    }
}
