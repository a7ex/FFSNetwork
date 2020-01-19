//
//  ServerConnection.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// ServerConnection
/// Runs network dataTasks. Uses URLSession, which can be provided at initialization
/// Required parameter to initialize is a configuration conforming to protocol ServerConfiguring
///
/// If used with requests, which conform to TypedNetworkRequest, then the result success value
/// will match the type defined in the requests mapResponse() function value return type.
///
/// ```
///    struct Backend {
///        private let serverConnection: ServerConnection
///
///        init(_ serverConfiguration: ServerConfiguring) {
///            serverConnection = ServerConnection(configuration: serverConfiguration)
///        }
///
///        func loadSomeText(_ completion: @escaping (Result<StringResponse, Error>) -> Void) {
///            let request = BackendRequest<StringResponse>(path: "/someText")
///            serverConnection.runTypedTaskWith(request, completion: completion)
///        }
///    }
///```
/// Then you can create your own structs conforming to "TypedNetworkResponse" with custom return types.
/// The above example returns a StringResponse. StringResponse is a built-in response, which just
/// converts the recieved data into a utf-8 string, if prossible.
///
/// In the 'Examples' folder is a ExampleRequest, ExampleResponse and ExampleConfiguration file.
/// Those examples illustrate the usage of ServerConnection for typed results.
/// Note that for typed results you can use the built-in 'BackendRequest' struct with just a custom "TypedNetworkResponse" type
///
/// If you add the example files to your project you then can add the following method to your Backend struct:
/// ```
///     func loadTodos(_ completion: @escaping (Result<FetchTodosResponse, Error>) -> Void) {
///         let request = FetchTodosRequest()
///         serverConnection.runTypedTaskWith(request, completion: completion)
///     }
/// ```
/// Now when using the 'Backend' in the UI Layer (UIViewController subclass) you get back an array of 'Todo' objects.
///
/// ```
///    import UIKit
///
///    class TodosViewController: UIViewController {
///        private var todos = [Todo]()
///        private var backend: Backend!
///
///        override func viewDidLoad() {
///            super.viewDidLoad()
///
///            let serverConfiguration = StagingConfiguration()
///            // if this crashes, it's a misconfigured serverConfiguration:
///            backend = try! Backend(serverConfiguration)
///
///            loadTodos()
///        }
///
///         func loadTodos() {
///             backend.loadTodos { result in
///                 if case let .success(response) = result {
///                     DispatchQueue.main.async {
///                         self.todos = response.value
///                         // refresh UI now...
///                     }
///                 }
///             }
///        }
///     }
/// ```
///
public final class ServerConnection {
    private let urlSession: DataTaskCreator
    private let serverConfiguration: ServerConfiguring
    private let messageHandler: ((String, CFAbsoluteTime) -> Void)
    
    /// Create an instance of a server connection using a configuration of type ServerConfiguring
    /// optionally takes a sessionConfiguration of type URLSessionConfiguration. Defaults to the default configuration
    ///
    /// - Parameters:
    ///   - configuration:  a struct that conforms to ServerConfiguring (providing host name and scheme)
    ///   - urlSessionConfiguration: pass in your own URLSession, if you have special requirements
    ///                                              e.g custom URLSessionConfiguration, URLSessionDelegate
    ///                                              if nil, defaults to URLSession with default URLSessionConfiguration
    ///   - messageHandler:  an opptional closure to receive status messages as loggable strings (useful for debugging)
    public init(configuration: ServerConfiguring,
                urlSession: DataTaskCreator? = nil,
                messageHandler: (@escaping (String, CFAbsoluteTime) -> Void) = { _, _ in}) {
        self.serverConfiguration = configuration
        self.urlSession = urlSession ?? URLSession(configuration: URLSessionConfiguration.default)
        self.messageHandler = messageHandler
    }
    
    //MARK: - Regular return values: Data?, URLResponse? and Error?
    
    /// Sends the given request.
    /// If scheme and host are not set in the request.url, they will be set with the backendURL of this ServerConnection
    /// otherwise a regular dataTask is run on URLSession
    /// No strong typed result, just regular optional Data
    ///
    /// - parameter request: A URLRequest to be sent.
    /// - parameter completion: A callback to invoke when the request completed.
    func sendRequest(_ request: URLRequest,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        sendNetworkRequest(request, completion: completion)
    }
    
    /// Sends the given request.
    /// If scheme and host are not set in the request.url, they will be set with the backendURL of this ServerConnection
    /// otherwise a regular dataTask is run on URLSession
    /// No strong typed result, just regular optional Data
    ///
    /// - parameter request: The request of type NetworkRequest to be sent.
    /// - parameter completion: A callback to invoke when the request completed.
    func sendNetworkRequest<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
        ) {
        runTaskWith(request) { result in
            switch result {
            case .failure(let error):
                if let serverConnectionError = error as? ServerConnectionError {
                    if case let .httpErrorNotNil(underlyingError, _, response, data) = serverConnectionError {
                        completion(data, response, underlyingError)
                        return
                    }
                }
                completion(nil, nil, error)
            case .success(let resultData):
                completion(resultData?.data, resultData?.response, resultData?.error)
            }
        }
    }
    
    //MARK: - Untyped Result
    
    /// Create and automatically run a request on this server connection
    /// Just uses createTaskWith()
    ///
    /// - Parameters:
    ///   - request: a struct that conforms to protocol NetworkRequest (URLRequest can adopt it)
    ///   - completion: a Result type with the success type *Optional Data*
    public func runTaskWith<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Result<NetworkResultData?, Error>) -> Void
        ) {
        do {
            let task = try createTaskWith(request, completion: completion)
            task.resume()
        }
        catch {
            completion(Result.failure(error))
        }
    }
    
    /// Create a dataTask on the URLSession of this server connection
    ///
    /// - Parameters:
    ///   - request: a struct that conforms to protocol NetworkRequest (URLRequest can adopt it)
    ///   - completion: a Result type with the success type *Optional Data*
    /// - Returns: URLSessionTask
    /// - Throws: throws error, when urlRequest couldn't be created (invalid request)
    public func createTaskWith<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Result<NetworkResultData?, Error>) -> Void
        ) throws -> URLSessionTask {
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            let urlRequest = try serverConfiguration.createURLRequest(with: request)
            messageHandler(urlRequest.formattedURLRequest, 0)
            return urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                if let error = error {
                    self?.messageHandler(error.localizedDescription, CFAbsoluteTimeGetCurrent() - startTime)
                    completion(Result.failure(ServerConnectionError.httpErrorNotNil(error, urlRequest, response, data)))
                } else {
                    self?.messageHandler(response?.formattedURLResponse ?? "- No response data! -", CFAbsoluteTimeGetCurrent() - startTime)
                    completion(Result.success(NetworkResultData(data: data, response: response, error: error)))
                }
            }
        } catch {
            throw error
        }
    }
    
    //MARK: - Strongly Typed Result
    
    /// Create and automatically run a request on this server connection
    /// Just uses createTaskWith()
    ///
    /// - Parameters:
    ///   - request: a struct that conforms to protocol TypedNetworkRequest
    ///   - completion: a Result type with the success type defined in the request
    public func runTaskWith<T: TypedNetworkRequest>(
        _ request: T,
        completion: @escaping (Result<T.ReturnType, Error>) -> Void
        ) {
        do {
            let task = try createTaskWith(request, completion: completion)
            task.resume()
        }
        catch {
            completion(Result.failure(error))
        }
    }

    /// Create a dataTask on the URLSession of this server connection
    ///
    /// - Parameters:
    ///   - request: a struct that conforms to protocol TypedNetworkRequest
    ///   - completion: a Result type with the success type defined in the request
    /// - Returns: URLSessionTask
    /// - Throws: throws error, when urlRequest couldn't be created (invalid request)
    public func createTaskWith<T: TypedNetworkRequest>(
        _ request: T,
        completion: @escaping (Result<T.ReturnType, Error>) -> Void
        ) throws -> URLSessionTask {
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            let urlRequest = try serverConfiguration.createURLRequest(with: request)
            messageHandler(urlRequest.formattedURLRequest, 0)
            return urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                if let error = error {
                    self?.messageHandler(error.localizedDescription, CFAbsoluteTimeGetCurrent() - startTime)
                    completion(Result.failure(ServerConnectionError.httpErrorNotNil(error, urlRequest, response, data)))
                    return
                }
                do {
                    self?.messageHandler(response?.formattedURLResponse ?? "- No response data! -", CFAbsoluteTimeGetCurrent() - startTime)
                    let resp = try request.mapResponse(data, response, urlRequest)
                    completion(Result.success(resp))
                } catch {
                    completion(Result.failure(ServerConnectionError.dataDecodingError(error, urlRequest, response, data)))
                }
            }
        } catch {
            throw error
        }
    }
}

public protocol DataTaskCreator {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
extension URLSession: DataTaskCreator { }
