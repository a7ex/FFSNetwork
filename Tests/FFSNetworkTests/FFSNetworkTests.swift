import XCTest
@testable import FFSNetwork

final class FFSNetworkTests: XCTestCase {
    
    // This is a questionable test, muts come up with better ones
    func testNoDataNoErrorCase() {
        let serverMock = MockData.URLSessionMock(
            mockURLSessionDataTask: MockData.MockURLSessionDataTask(
                expectedData: nil,
                expectedResponse: nil,
                expectedError: nil,
                completionHandler: nil
            )
        )
        let serverConnection = ServerConnection(configuration: MockData.ServerConfigurationMock(), urlSession: serverMock)
        
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
        
        let expectation2 = self.expectation(description: "Simple request with Result Type")
        serverConnection.runTaskWith(request) { result in
            if case let Result.success(rslt) = result {
                XCTAssertNil(rslt?.data)
                XCTAssertNil(rslt?.response)
                XCTAssertNil(rslt?.error)
            } else {
                XCTFail()
            }
            expectation2.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
        
        let expectation3 = self.expectation(description: "StringResponse request")
        let typedRequest = BackendRequest<StringResponse>()
        
        serverConnection.runTaskWith(typedRequest) { (result: Result<StringResponse, Error>) in
            if case let Result.success(rslt) = result {
                XCTAssert(rslt.value == "")
                XCTAssertNil(rslt.urlResponse)
            } else {
                XCTFail()
            }
            expectation3.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    static var allTests = [
        ("testNoDataNoErrorCase", testNoDataNoErrorCase),
    ]
}
