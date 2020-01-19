//
//  CombineServer.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 17.08.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13.0, *)

/// NSURLSession using Combine
/// Use FFSNetwork package for SwiftUI + Combine as well :-)
///
/// Example:
/// ```
///     import SwiftUI
///     import Combine
///     import FFSNetwork
///
///     struct ContentView: View {
///         private let backend = BackendCombine()
///         @State private var todos = [Todo]()
///         @State private var cancellable: Cancellable? = nil
///
///         var body: some View {
///             List(todos) { todo in
///                 HStack {
///                     Text(todo.title)
///                     Spacer()
///                     if todo.completed {
///                         Image(systemName: "checkmark")
///                     }
///                 }
///                 .padding([.leading, .trailing], 8)
///             }
///             .onAppear {
///                 self.loadTodos()
///             }
///         }
///
///         func loadTodos() {
///             cancellable = backend
///                 .loadTodosAsTodoResponse()
///                 .sink(receiveCompletion: { (error) in
///                     // if error != nil then handle the error
///                 }, receiveValue: { (response) in
///                     self.todos = response.value
///                 })
///         }
///     }
///
///     struct ContentView_Previews: PreviewProvider {
///         static var previews: some View {
///             ContentView()
///         }
///     }
/// ```

public struct CombineServer {
    private let urlSession: URLSession
    private let serverConfiguration: ServerConfiguring
    private let messageHandler: ((String, CFAbsoluteTime) -> Void)
    
    public init(configuration: ServerConfiguring,
                urlSession: URLSession = .shared,
                messageHandler: (@escaping (String, CFAbsoluteTime) -> Void) = { _, _ in}) {
        self.serverConfiguration = configuration
        self.urlSession = urlSession
        self.messageHandler = messageHandler
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
        let startTime = CFAbsoluteTimeGetCurrent()
        messageHandler(urlRequest.formattedURLRequest, 0)
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map {
                self.messageHandler($0.response.formattedURLResponse, CFAbsoluteTimeGetCurrent() - startTime)
                return $0.data
        }
        .compactMap { String(data: $0, encoding: encoding) }
        .eraseToAnyPublisher()
    }
    
    /// Run a request and receive a JSON object upon success
    /// The generic return type U must conform to the Decodable protocol
    /// - Parameter request: a request which conforms to NetworkRequest (URLRequest does)
    public func runJSONTaskWith<T: NetworkRequest, U>(_ request: T) -> AnyPublisher<U, ServerConnectionError> where U: Decodable {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        let startTime = CFAbsoluteTimeGetCurrent()
        let decoder = JSONDecoder()
        messageHandler(urlRequest.formattedURLRequest, 0)
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map {
                self.messageHandler($0.response.formattedURLResponse, CFAbsoluteTimeGetCurrent() - startTime)
                return $0.data
            }
            .decode(type: U.self, decoder: decoder)
            .mapError { error in
                if let error = error as? ServerConnectionError {
                    return error
                } else {
                    return ServerConnectionError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Run a typed request and receive the requested type upon success
    /// - Parameter request: a request which conforms to TypedNetworkRequest
    public func runTypedTaskWith<T: TypedNetworkRequest>(_ request: T) ->
        AnyPublisher<T.ReturnType, ServerConnectionError> where T.ReturnType.ResponseType: Decodable {
            guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
                preconditionFailure("Unable to create URLRequest from request: \(request)")
            }
            let startTime = CFAbsoluteTimeGetCurrent()
            messageHandler(urlRequest.formattedURLRequest, 0)
            return urlSession.dataTaskPublisher(for: urlRequest)
                .tryMap {
                    self.messageHandler($0.response.formattedURLResponse, CFAbsoluteTimeGetCurrent() - startTime)
                    return try request.mapResponse($0.data, $0.response, urlRequest)
                }
                .mapError { error in
                    if let error = error as? ServerConnectionError {
                        return error
                    } else {
                        return ServerConnectionError.apiError(reason: error.localizedDescription)
                    }
                }
                .eraseToAnyPublisher()
    }
}

@available(OSX 10.15, iOS 13.0, *)
public protocol DataTaskPublisherCreator {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

@available(OSX 10.15, iOS 13.0, *)
extension URLSession: DataTaskPublisherCreator { }
