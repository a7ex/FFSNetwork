import XCTest
@testable import FFSNetwork

class FFSNetworkTests: XCTestCase {
    
    func testNoDataNoErrorCaseUrlRequestSend() {
        let expectation = self.expectation(description: "Simple request")
        
        let url = URL(string: "https://www.google.com")!
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: nil,
            response: nil,
            error: nil,
            url: url
        )
        
        let request = URLRequest(url: url)
        serverConnection.sendRequest(request) { (data, response, error) in
            XCTAssertNil(error)
            if let data = data {
                XCTAssertTrue(data.isEmpty)
            }
            XCTAssertNil(response)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testAllDataCaseUrlRequestSend() {
        let expectation = self.expectation(description: "Simple request")
        
        let url = URL(string: "https://www.google.com")!
        let expectedString = "This is data"
        let expectedErrorText = "This is an error"
        
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
                    url: url,
                    mimeType: "text/plain",
                    expectedContentLength: expectedData.count,
                    textEncodingName: "utf-8"
                )
        let expectedError = NSError(
                    domain: "de.farbflash",
                    code: 200,
                    userInfo: ["description": expectedErrorText]
                )
        
        let serverConnection = Mocks.mockedSessionServerReturning(data: expectedData, response: expectedResponse, error: expectedError, url: url)
        
        let request = URLRequest(url: url)
        serverConnection.sendRequest(request) { (data, response, error) in
            XCTAssertEqual(error?.localizedDescription, "The operation couldn’t be completed. (\(expectedError.domain) error \(expectedError.code).)")
            if let error = error {
                XCTAssertEqual((error as NSError).code, expectedError.code)
                XCTAssertEqual((error as NSError).userInfo["description"] as! String, expectedErrorText)
            } else {
                XCTFail("Expected error with code \(expectedError.code)")
            }
            if let data = data {
                XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
            } else {
                XCTFail("Expected data '\(expectedString)'")
            }
            if let response = response {
                XCTAssertTrue(response.corresponds(to: expectedResponse))
            } else {
                XCTFail("Expected http response")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testNoDataNoErrorCaseUrlRequestRun() {
        let expectation = self.expectation(description: "Using URLRequest instead of NetworkRequest")
        
        let url = URL(string: "https://www.google.com")!
        
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: nil,
            response: nil,
            error: nil,
            url: url
        )
        
        let request = URLRequest(url: url)
        serverConnection.runTaskWith(request) { result in
            if case let Result.success(rslt) = result {
                XCTAssertTrue(rslt?.data?.isEmpty ?? true)
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
        let expectation = self.expectation(description: "Simple request")
        
        let url = URL(string: "https://www.farbflash.de")!
        let expectedString = "This is data"
        
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let serverConnection = Mocks.mockedRequestServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        let request = URLRequest(url: url)
        serverConnection.runTaskWith(request) { result in
            if case let Result.success(rslt) = result {
                guard let rslt = rslt else {
                    XCTFail("Successful result should exist")
                    return
                }
                XCTAssertNil(rslt.error)
                if let data = rslt.data {
                    XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
                } else {
                    XCTFail("Data should be '\(expectedString)'")
                }
                if let response = rslt.response {
                    XCTAssertTrue(response.corresponds(to: expectedResponse))
                } else {
                    XCTFail("Response should exist")
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
    
    func testErrorCaseUrlRequestRun() {
        let expectation = self.expectation(description: "Simple request")
        
        let url = URL(string: "https://www.google.com")!
        let expectedString = "This is data"
        let expectedErrorString = "This is an error"
        
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let expectedError = NSError(
            domain: "de.farbflash",
            code: 17,
            userInfo: ["description": expectedErrorString]
        )
        let serverConnection = Mocks.mockedSessionServerReturning(data: expectedData, response: expectedResponse, error: expectedError, url: url)
        
        let request = URLRequest(url: url)
        serverConnection.runTaskWith(request) { result in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), expectedError.localizedDescription)
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .httpErrorNotNil(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                        XCTAssertEqual((error as NSError).code, expectedError.code)
                        XCTAssertEqual((error as NSError).userInfo["description"] as! String, expectedErrorString)
                        if let data = data {
                            XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
                        } else {
                            XCTFail("Data should be '\(expectedString)'")
                        }
                        if let response = urlResponse {
                            XCTAssertTrue(response.corresponds(to: expectedResponse))
                        } else {
                            XCTFail("Response should exist")
                        }
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
        let expectation = self.expectation(description: "StringResponse request")
        
        let url = Mocks.mockUrlComponents.url!
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: nil,
            response: nil,
            error: nil,
            url: url
        )
        
        let typedRequest = TypedRequest<StringResponse>()
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
        let expectation = self.expectation(description: "StringResponse request")
       
        let url = Mocks.mockUrlComponents.url!
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: nil,
            response: nil,
            error: nil,
            url: url
        )
        
        let typedRequest = FetchTodosRequest()
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(rslt) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(rslt), "Error decoding data. (Error: The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 0.))")
                if let serverConnectionError = rslt as? ServerConnectionError {
                    if case let .dataDecodingError(error, request, response, data) = serverConnectionError {
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 0.)")
                        
                        if let jsonResponseError = error as? JSONResponseError {
                            if case let .noData(xresponse) = jsonResponseError {
                                XCTAssertNil(xresponse)
                            } else {
                                XCTFail()
                            }
                        } else {
                            XCTFail()
                        }
                        XCTAssertEqual(request.url?.absoluteString, url.absoluteString + typedRequest.path)
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
        let expectation = self.expectation(description: "StringResponse request")
        
        let typedRequest = FetchTodosRequest()
        let expectedString = "Not json"
        
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: expectedData,
            response: nil,
            error: nil,
            url: url
        )
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(rslt) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(rslt), "Error decoding data. (Error: The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.))")
                if let serverConnectionError = rslt as? ServerConnectionError {
                    if case let .dataDecodingError(error, request, response, data) = serverConnectionError {
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.)")
                        if let jsonResponseError = error as? JSONResponseError {
                            if case let .decodingError(decoderError, trequest, tresponse, dataAsString) = jsonResponseError {
                                XCTAssertEqual(decoderError.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
                                XCTAssertEqual(trequest.url?.absoluteString, url.absoluteString)
                                XCTAssertNil(tresponse)
                                XCTAssertEqual(dataAsString, expectedString)
                            } else {
                                XCTFail("Wrong error")
                            }
                        } else {
                            XCTFail("Wrong error")
                        }
                        XCTAssertEqual(request.url?.absoluteString, url.absoluteString)
                        XCTAssertNil(response)
                        if let data = data {
                            XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
                        } else {
                            XCTFail("Data should be the string '\(expectedString)'")
                        }
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
        let expectation = self.expectation(description: "StringResponse request")
        
        let typedRequest = TypedRequest<StringResponse>()
        
        let expectedString = "{userId: 1, id: 1, title: \"Todo title\", completed: true}"
        
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.success(rslt) = result {
                XCTAssertEqual(rslt.value, expectedString)
                if let response = rslt.urlResponse {
                    XCTAssertTrue(response.corresponds(to: expectedResponse))
                } else {
                    XCTFail("Expected http response")
                }
                XCTAssertEqual(rslt.sentRequest.url?.absoluteString, url.absoluteString)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testSuccessCaseTodoNetworkRequestRun() {
        let expectation = self.expectation(description: "StringResponse request")
        
        let typedRequest = FetchTodosRequest()
        
        let expectedString = "[{\"userId\": 1, \"id\": 1, \"title\": \"Todo title\", \"completed\": true}]"
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let serverConnection = Mocks.mockedRequestServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.success(rslt) = result {
                if let todo = rslt.value.first {
                    XCTAssertEqual(todo.title, "Todo title")
                    XCTAssertEqual(todo.id, 1)
                    XCTAssertEqual(todo.userId, 1)
                    XCTAssertEqual(todo.completed, true)
                } else {
                    XCTFail("There should be one element")
                }
                if let response = rslt.urlResponse {
                    XCTAssertTrue(response.corresponds(to: expectedResponse))
                } else {
                    XCTFail("Expected http response")
                }
                XCTAssertEqual(rslt.sentRequest.url?.absoluteString, url.absoluteString)
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
        let expectation = self.expectation(description: "StringResponse request")
        
        let typedRequest = TypedRequest<StringResponse>()
        
        let expectedString = "{userId: 1, id: 1, title: \"Todo title\", completed: true}"
        let expectedErrorString = "This is an error"
        
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        URLProtocolMock.testURLs = [url: expectedData]
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        let expectedError = NSError(
            domain: "de.farbflash",
            code: 17,
            userInfo: ["description": expectedErrorString]
        )
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: expectedError,
            url: url
        )
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "The operation couldn’t be completed. (\(expectedError.domain) error \(expectedError.code).)")
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .httpErrorNotNil(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (\(expectedError.domain) error \(expectedError.code).)")
                        XCTAssertEqual((error as NSError).code, 17)
                        XCTAssertEqual((error as NSError).userInfo["description"] as! String, expectedErrorString)
                        if let data = data {
                        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
                        } else {
                            XCTFail("Data should exist")
                        }
                        if let response = urlResponse {
                            XCTAssertTrue(response.corresponds(to: expectedResponse))
                        } else {
                            XCTFail("Expected http response")
                        }
                        XCTAssertEqual(urlRequest.url?.absoluteString, url.absoluteString)
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
        let expectation = self.expectation(description: "ParseErrorCase request")
        
        let typedRequest = FetchTodosRequest()
        let expectedString = "userId: 1, id: 1, title: \"Todo title\", completed: true}"
        
        let url = Mocks.mockUrlComponents.url!.appendingPathComponent(typedRequest.path)
        let expectedData = expectedString.data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: url,
            mimeType: "text/plain",
            expectedContentLength: expectedData.count,
            textEncodingName: "utf-8"
        )
        
        let serverConnection = Mocks.mockedSessionServerReturning(
            data: expectedData,
            response: expectedResponse,
            error: nil,
            url: url
        )
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<FetchTodosResponse, Error>) in
            if case let Result.failure(error) = result {
                XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Error decoding data. (Error: The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.))")
                
                if let error = error as? ServerConnectionError {
                    switch error {
                    case .dataDecodingError(let error, let urlRequest, let urlResponse, let data):
                        XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (FFSNetwork.JSONResponseError error 1.)")
                        if let data = data {
                        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
                        } else {
                            XCTFail("Data should exist")
                        }
                        XCTAssertEqual(urlRequest.url?.absoluteString, url.absoluteString)
                        
                        if let response = urlResponse {
                            XCTAssertTrue(response.corresponds(to: expectedResponse))
                        } else {
                            XCTFail("Expected http response")
                        }
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
        let request = TypedRequest<StringResponse>(path: "/todos",
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
        if let data = request.httpBody {
            XCTAssertEqual(String(data: data, encoding: .utf8), "This is the body")
        } else {
            XCTFail("Data should be 'This is the body'")
        }
        XCTAssertEqual(request.cachePolicy, .returnCacheDataDontLoad)
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertNil(request.baseUrl)
    }
    
    func testBackendRequestSetHeader() {
        var request = TypedRequest<StringResponse>()
        request.setValue("header value", forHTTPHeaderField: "header key")
        XCTAssertEqual(request.allHTTPHeaderFields, ["header key": "header value"])
        
    }
    
    func testBackendRequestURLRequestCreation() throws {
        let configuration = ProductionConfiguration()
        
        let request = TypedRequest<StringResponse>(path: "/todos",
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
        if let data = urlRequest.httpBody {
            XCTAssertEqual(String(data: data, encoding: .utf8), "This is the body")
        } else {
            XCTFail("Data should be 'This is the body'")
        }
        XCTAssertEqual(urlRequest.cachePolicy, request.cachePolicy)
        XCTAssertEqual(urlRequest.timeoutInterval, request.timeoutInterval)
        
        let requestWithBaseUrlOverride = TypedRequest<StringResponse>(baseUrl: URL(string: "http://www.farbflash.de")!)
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
    
    func testTodosRequestHeaders() {
        var request = FetchTodosRequest(headers: nil)
        XCTAssertEqual(request.path, "/todos")
        XCTAssertNil(request.allHTTPHeaderFields?["Accept"])
        XCTAssertEqual(request.method, .get)
        request.setValue("Custom value", forHTTPHeaderField: "Custom key")
        XCTAssertEqual(request.allHTTPHeaderFields?["Custom key"], "Custom value")
    }
    
    static var allTests = [
        ("testNoDataNoErrorCaseUrlRequestSend", testNoDataNoErrorCaseUrlRequestSend),
    ]
}
