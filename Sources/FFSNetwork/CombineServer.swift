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

@available(swift 5.1)
@available(OSX 10.15, iOS 13.0, *)
public struct CombineServer {
    private let urlSession: URLSession
    private let serverConfiguration: ServerConfiguring
    private let messageHandler: ((String, CFAbsoluteTime) -> Void)

    /// Enable/disable here whether to log full results or only a summary in order to reduce clutter in the console
    private let loglevel: FFSLogLevel
    private static var correlationId = 0

    public init(configuration: ServerConfiguring,
                urlSession: URLSession = .shared,
                logLevel: FFSLogLevel = .isPrivate,
                messageHandler: (@escaping (String, CFAbsoluteTime) -> Void) = { _, _ in}) {
        self.serverConfiguration = configuration
        self.urlSession = urlSession
        self.messageHandler = messageHandler
        self.loglevel = logLevel
    }
}

@available(swift 5.1)
@available(OSX 10.15, iOS 13.0, *)
extension CombineServer {

    /// Run a request and receive a string response upon success
    /// - Parameter request: a request which conforms to NetworkRequest (URLRequest does)
    /// - Parameter encoding: the expected string encoding of the response data
    public func runStringTaskWith<T: NetworkRequest>(_ request: T, encoding: String.Encoding = .utf8) -> AnyPublisher<String, URLError> {
        guard let urlRequest = try? serverConfiguration.createURLRequest(with: request) else {
            preconditionFailure("Unable to create URLRequest from request: \(request)")
        }
        Self.correlationId += 1
        let startTime = CFAbsoluteTimeGetCurrent()
        let ticketNumber = Self.correlationId
        var logString = urlRequest.formattedURLRequest(verbose: loglevel == .isVerbose, correlationId: "\(ticketNumber)")
        if loglevel == .isVerbose {
            logString += "\nADDITIONAL HEADERS: \(String(describing: urlSession.configuration.httpAdditionalHeaders))"
        }
        messageHandler(logString, 0)
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map {
                var responseLogString = $0.response.formattedURLResponse(
                    verbose: self.loglevel == .isVerbose,
                    correlationId: "\(ticketNumber)",
                    elapsed: CFAbsoluteTimeGetCurrent() - startTime)
                responseLogString += ServerConnection.getDataPrintOutput(for: $0.data, logLevel: self.loglevel)
                self.messageHandler(responseLogString, CFAbsoluteTimeGetCurrent() - startTime)
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
        Self.correlationId += 1
        let startTime = CFAbsoluteTimeGetCurrent()
        let ticketNumber = Self.correlationId
        var logString = urlRequest.formattedURLRequest(verbose: loglevel == .isVerbose, correlationId: "\(ticketNumber)")
        if loglevel == .isVerbose {
            logString += "\nADDITIONAL HEADERS: \(String(describing: urlSession.configuration.httpAdditionalHeaders))"
        }
        messageHandler(logString, 0)
        let decoder = JSONDecoder()
        return urlSession.dataTaskPublisher(for: urlRequest)
            .map {
                var responseLogString = $0.response.formattedURLResponse(
                    verbose: self.loglevel == .isVerbose,
                    correlationId: "\(ticketNumber)",
                    elapsed: CFAbsoluteTimeGetCurrent() - startTime)
                responseLogString += ServerConnection.getDataPrintOutput(for: $0.data, logLevel: self.loglevel)
                self.messageHandler(responseLogString, CFAbsoluteTimeGetCurrent() - startTime)
                return $0.data
            }
            .decode(type: U.self, decoder: decoder)
            .mapError { error in
                self.messageHandler("ERROR (\(ticketNumber)): \(String(describing: error))", CFAbsoluteTimeGetCurrent() - startTime)
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
        Self.correlationId += 1
        let startTime = CFAbsoluteTimeGetCurrent()
        let ticketNumber = Self.correlationId
        var logString = urlRequest.formattedURLRequest(verbose: loglevel == .isVerbose, correlationId: "\(ticketNumber)")
        if loglevel == .isVerbose {
            logString += "\nADDITIONAL HEADERS: \(String(describing: urlSession.configuration.httpAdditionalHeaders))"
        }
        messageHandler(logString, 0)
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap {
                var responseLogString = $0.response.formattedURLResponse(
                    verbose: self.loglevel == .isVerbose,
                    correlationId: "\(ticketNumber)",
                    elapsed: CFAbsoluteTimeGetCurrent() - startTime)
                responseLogString += ServerConnection.getDataPrintOutput(for: $0.data, logLevel: self.loglevel)
                self.messageHandler(responseLogString, CFAbsoluteTimeGetCurrent() - startTime)
                return try request.mapResponse($0.data, $0.response, urlRequest)
            }
            .mapError { error in
                self.messageHandler("ERROR (\(ticketNumber)): \(String(describing: error))", CFAbsoluteTimeGetCurrent() - startTime)
                if let error = error as? ServerConnectionError {
                    return error
                } else {
                    return ServerConnectionError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

@available(swift 5.1)
@available(OSX 10.15, iOS 13.0, *)
public protocol DataTaskPublisherCreator {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

@available(swift 5.1)
@available(OSX 10.15, iOS 13.0, *)
extension URLSession: DataTaskPublisherCreator { }
