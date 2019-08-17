//
//  CombineServer.swift
//  
//
//  Created by Alex da Franca on 17.08.19.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13.0, *)
public struct CombineServer {
    private let urlSession: URLSession
    private let serverConfiguration: ServerConfiguring
    private let decoder: JSONDecoder
    
    public init(configuration: ServerConfiguring,
                urlSession: URLSession = .shared,
                decoder: JSONDecoder = .init()) {
        self.serverConfiguration = configuration
        self.urlSession = urlSession
        self.decoder = decoder
    }
}

@available(OSX 10.15, iOS 13.0, *)
extension CombineServer {
    public func runTaskWith<T: TypedNetworkRequest>(
        _ request: T) -> AnyPublisher<T.ReturnType, Error> where T.ReturnType: Decodable {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: T.ReturnType.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
