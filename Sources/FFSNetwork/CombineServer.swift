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
    
    public init(configuration: ServerConfiguring,
                urlSession: URLSession = .shared) {
        self.serverConfiguration = configuration
        self.urlSession = urlSession
    }
}

@available(OSX 10.15, iOS 13.0, *)
extension CombineServer {
    
    /// Run a request and receive a string response upon success
    /// - Parameter request: a request which conforms to NetworkRequest (URLRequest does)
    /// - Parameter encoding: the expected string encoding of the response data
    public func runStringTaskWith<T: NetworkRequest>(_ request: T, encoding: String.Encoding = .utf8) -> AnyPublisher<String, URLError> {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .compactMap { String(data: $0, encoding: encoding) }
            .eraseToAnyPublisher()
    }
    
    /// Run a request and receive a JSON object upon success
    /// The generic return type U must conform to the Decodable protocol
    /// - Parameter request: a request which conforms to NetworkRequest (URLRequest does)
    public func runJSONTaskWith<T: NetworkRequest, U>(_ request: T) -> AnyPublisher<U, Error> where U: Decodable {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        let decoder = JSONDecoder()
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: U.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    /// Run a typed request and receive the requested type upon success
    /// - Parameter request: a request which conforms to TypedNetworkRequest
    public func runTaskWith<T: TypedNetworkRequest>(_ request: T) ->
        AnyPublisher<T.ReturnType, Error> where T.ReturnType.ResponseType: Decodable {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { try request.mapResponse($0.data, $0.response, urlRequest) }
            .eraseToAnyPublisher()
    }
}
