//
//  BackendCombine.swift
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
struct BackendCombine {
    private let serverConnection: CombineServer
    
    init(_ serverConfiguration: ServerConfiguring = StagingConfiguration()) {
        serverConnection = CombineServer(configuration: serverConfiguration)
    }
}

@available(OSX 10.15, iOS 13, *)
extension BackendCombine {
    
    func loadTodosAsTodoResponse() -> AnyPublisher<FetchTodosResponse, ServerConnectionError> {
        return serverConnection.runTypedTaskWith(FetchTodosRequest())
    }
    
    func loadTodosAsJSONRequest() -> AnyPublisher<[Todo], ServerConnectionError> {
        let request = Request(path: "/todos")
        return serverConnection.runJSONTaskWith(request)
    }
}
