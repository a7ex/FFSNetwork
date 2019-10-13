import XCTest
@testable import FFSNetwork

final class FFSNetworkTests: XCTestCase {
    
    func testNoDataNoErrorCaseUrlRequestSend() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: nil, response: nil, error: nil)
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        let expectation = self.expectation(description: "Simple request")
        serverConnection.sendRequest(request) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNil(data)
            XCTAssertNil(response)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testAllDataCaseUrlRequestSend() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "This is data".data(using: .utf8), response: URLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: NSError(domain: "de.farbflash", code: 17, userInfo: ["description": "This is an error"]))
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        let expectation = self.expectation(description: "Simple request")
        serverConnection.sendRequest(request) { (data, response, error) in
            XCTAssertEqual(error!.localizedDescription, "The operation couldn’t be completed. (de.farbflash error 17.)")
            XCTAssertEqual((error! as NSError).code, 17)
            XCTAssertEqual((error! as NSError).userInfo["description"] as! String, "This is an error")
            XCTAssertEqual(String(data: data!, encoding: .utf8), "This is data")
            XCTAssertEqual(response!.url!.absoluteString, "http://www.farbflash.de")
            XCTAssertEqual(response!.mimeType, "text/plain")
            XCTAssertEqual(response!.expectedContentLength, 17)
            XCTAssertEqual(response!.textEncodingName, "utf-8")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testNoDataNoErrorCaseUrlRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: nil, response: nil, error: nil)
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        let expectation = self.expectation(description: "Using URLRequest instead of NetworkRequest")
        serverConnection.runTaskWith(request) { result in
            if case let Result.success(rslt) = result {
                XCTAssertNil(rslt?.data)
                XCTAssertNil(rslt?.response)
                XCTAssertNil(rslt?.error)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testSuccessCaseUrlRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "This is data".data(using: .utf8), response: URLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: nil)
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        let expectation = self.expectation(description: "Simple request")
        serverConnection.runTaskWith(request) { result in
            if case let Result.success(rslt) = result {
                XCTAssertNil(rslt!.error)
                XCTAssertEqual(String(data: rslt!.data!, encoding: .utf8), "This is data")
                XCTAssertEqual(rslt!.response!.url!.absoluteString, "http://www.farbflash.de")
                XCTAssertEqual(rslt!.response!.mimeType, "text/plain")
                XCTAssertEqual(rslt!.response!.expectedContentLength, 17)
                XCTAssertEqual(rslt!.response!.textEncodingName, "utf-8")
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testErrorCaseUrlRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "This is data".data(using: .utf8), response: URLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: NSError(domain: "de.farbflash", code: 17, userInfo: ["description": "This is an error"]))
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        let expectation = self.expectation(description: "Simple request")
        serverConnection.runTaskWith(request) { result in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Server error")
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .httpErrorNotNil(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (de.farbflash error 17.)")
                        XCTAssertEqual((error as NSError).code, 17)
                        XCTAssertEqual((error as NSError).userInfo["description"] as! String, "This is an error")
                        XCTAssertEqual(String(data: data!, encoding: .utf8), "This is data")
                        XCTAssertEqual(urlResponse!.url!.absoluteString, "http://www.farbflash.de")
                        XCTAssertEqual(urlResponse!.mimeType, "text/plain")
                        XCTAssertEqual(urlResponse!.expectedContentLength, 17)
                        XCTAssertEqual(urlResponse!.textEncodingName, "utf-8")
                        XCTAssertEqual(request.url?.absoluteString, urlRequest.url?.absoluteString)
                    default:
                        XCTFail()
                    }
                }
                
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testNoDataNoErrorCaseTypedNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: nil, response: nil, error: nil)
        
        let typedRequest = BackendRequest<StringResponse>()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.success(rslt) = result {
                XCTAssert(rslt.value == "")
                XCTAssertNil(rslt.urlResponse)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testNoDataNoErrorCaseTypedJSONNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: nil, response: nil, error: nil)
        
        let typedRequest = FetchTodosRequest()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(rslt) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(rslt), "Error decoding data")
                if let serverConnectionError = rslt as? ServerConnectionError {
                    if case let .dataDecodingError(error, request, response, data) = serverConnectionError {
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 0.)")
                        let jsonResponseError = error as! JSONResponseError
                        if case let .noData(xresponse) = jsonResponseError {
                            XCTAssertNil(xresponse)
                        } else {
                            XCTFail()
                        }
                        XCTAssertEqual(request.url?.absoluteString, "https://jsonplaceholder.typicode.com/todos")
                        XCTAssertNil(response)
                        XCTAssertNil(data)
                    } else {
                        XCTFail()
                    }
                }
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testParseErrorCaseTypedJSONNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "Not json".data(using: .utf8), response: nil, error: nil)
        
        let typedRequest = FetchTodosRequest()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(rslt) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(rslt), "Error decoding data")
                if let serverConnectionError = rslt as? ServerConnectionError {
                    if case let .dataDecodingError(error, request, response, data) = serverConnectionError {
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.)")
                        let jsonResponseError = error as! JSONResponseError
                        if case let .decodingError(decoderError, trequest, tresponse, dataAsString) = jsonResponseError {
                            XCTAssertEqual(decoderError.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
                            XCTAssertEqual(trequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/todos")
                            XCTAssertNil(tresponse)
                            XCTAssertEqual(dataAsString, "Not json")
                        } else {
                            XCTFail("Wrong error")
                        }
                        XCTAssertEqual(request.url?.absoluteString, "https://jsonplaceholder.typicode.com/todos")
                        XCTAssertNil(response)
                        XCTAssertEqual(String(data: data!, encoding: .utf8), "Not json")
                    } else {
                        XCTFail()
                    }
                }
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testSuccessCaseTypedNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "{userId: 1, id: 1, title: \"Todo title\", completed: true}".data(using: .utf8), response: HTTPURLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: nil)
        
        let typedRequest = BackendRequest<StringResponse>()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.success(rslt) = result {
                XCTAssertEqual(rslt.value, "{userId: 1, id: 1, title: \"Todo title\", completed: true}")
                XCTAssertEqual(rslt.httpURLResponse!.url!.absoluteString, "http://www.farbflash.de")
                XCTAssertEqual(rslt.httpURLResponse!.mimeType, "text/plain")
                XCTAssertEqual(rslt.httpURLResponse!.expectedContentLength, 17)
                XCTAssertEqual(rslt.httpURLResponse!.textEncodingName, "utf-8")
                XCTAssertEqual(rslt.sentRequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/")
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testErrorCaseTypedNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "{userId: 1, id: 1, title: \"Todo title\", completed: true}".data(using: .utf8), response: URLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: NSError(domain: "de.farbflash", code: 17, userInfo: ["description": "This is an error"]))
        
        let typedRequest = BackendRequest<StringResponse>()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Server error")
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .httpErrorNotNil(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (de.farbflash error 17.)")
                        XCTAssertEqual((error as NSError).code, 17)
                        XCTAssertEqual((error as NSError).userInfo["description"] as! String, "This is an error")
                        XCTAssertEqual(String(data: data!, encoding: .utf8), "{userId: 1, id: 1, title: \"Todo title\", completed: true}")
                        XCTAssertEqual(urlResponse!.url!.absoluteString, "http://www.farbflash.de")
                        XCTAssertEqual(urlResponse!.mimeType, "text/plain")
                        XCTAssertEqual(urlResponse!.expectedContentLength, 17)
                        XCTAssertEqual(urlResponse!.textEncodingName, "utf-8")
                        XCTAssertEqual(urlRequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/")
                    default:
                        XCTFail()
                    }
                }
                
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testParseErrorCaseTypedNetworkRequestRun() {
        let serverConnection = MockData.serverConnectionWhichReturns(data: "userId: 1, id: 1, title: \"Todo title\", completed: true}".data(using: .utf8), response: URLResponse(url: URL(string: "http://www.farbflash.de")!, mimeType: "text/plain", expectedContentLength: 17, textEncodingName: "utf-8"), error: nil)
        
        let typedRequest = FetchTodosRequest()
        
        let expectation = self.expectation(description: "StringResponse request")
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Error decoding data")
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .dataDecodingError(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.)")
                        XCTAssertEqual(String(data: data!, encoding: .utf8), "userId: 1, id: 1, title: \"Todo title\", completed: true}")
                        XCTAssertEqual(urlRequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/todos")
                        
                        XCTAssertEqual(urlResponse!.url!.absoluteString, "http://www.farbflash.de")
                        XCTAssertEqual(urlResponse!.mimeType, "text/plain")
                        XCTAssertEqual(urlResponse!.expectedContentLength, 17)
                        XCTAssertEqual(urlResponse!.textEncodingName, "utf-8")
                    default:
                        XCTFail()
                    }
                }
                
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testBackendRequest() throws {
        let request = BackendRequest<StringResponse>(path: "/todos",
                                                     method: .post,
                                                     headers: ["header key": "header value"],
                                                     queryItems: [URLQueryItem(name: "Query item key", value: "Query item value ö")],
                                                     httpBody: "This is the body".data(using: .utf8),
                                                     cachePolicy: .returnCacheDataDontLoad,
                                                     timeoutInterval: TimeInterval(30),
                                                     baseUrl: nil)
        XCTAssertEqual(request.path, "/todos")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.allHTTPHeaderFields, ["header key": "header value"])
        XCTAssertEqual(request.queryItems?.first?.name, "Query item key")
        XCTAssertEqual(request.queryItems?.first?.value, "Query item value ö")
        XCTAssertEqual(String(data: request.httpBody!, encoding: .utf8), "This is the body")
        XCTAssertEqual(request.cachePolicy, .returnCacheDataDontLoad)
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertNil(request.baseUrl)
    }
    
    func testBackendRequestSetHeader() {
        var request = BackendRequest<StringResponse>()
        request.setValue("header value", forHTTPHeaderField: "header key")
        XCTAssertEqual(request.allHTTPHeaderFields, ["header key": "header value"])
        
    }
    
    func testBackendRequestURLRequestCreation() throws {
        let configuration = ProductionConfiguration()
        
        let request = BackendRequest<StringResponse>(path: "/todos",
                                                     method: .post,
                                                     headers: ["header key": "header value"],
                                                     queryItems: [URLQueryItem(name: "Query item key", value: "Query item value ö")],
                                                     httpBody: "This is the body".data(using: .utf8),
                                                     cachePolicy: .returnCacheDataDontLoad,
                                                     timeoutInterval: TimeInterval(30),
                                                     baseUrl: nil)
        
        let urlRequest = try configuration.createURLRequest(with: request)
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://production-api.example.com/todos?Query%20item%20key=Query%20item%20value%20%C3%B6")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["header key": "header value"])
        XCTAssertEqual(String(data: urlRequest.httpBody!, encoding: .utf8), "This is the body")
        XCTAssertEqual(urlRequest.cachePolicy, request.cachePolicy)
        XCTAssertEqual(urlRequest.timeoutInterval, request.timeoutInterval)
        
        let requestWithBaseUrlOverride = BackendRequest<StringResponse>(baseUrl: URL(string: "http://www.farbflash.de")!)
        XCTAssertEqual(requestWithBaseUrlOverride.baseUrl?.absoluteString, "http://www.farbflash.de")
        
        let urlRequestWithBaseUrlOverride = try configuration.createURLRequest(with: requestWithBaseUrlOverride)
        XCTAssertEqual(urlRequestWithBaseUrlOverride.url?.absoluteString, "http://www.farbflash.de/")
    }
    
    func testTodosRequest() {
        let request = FetchTodosRequest()
        XCTAssertEqual(request.path, "/todos")
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(request.method, .get)
    }
    
    static var allTests = [
        ("testNoDataNoErrorCaseUrlRequestSend", testNoDataNoErrorCaseUrlRequestSend),
    ]
}
