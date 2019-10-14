//
//  ErrorMessageProviderTests.swift
//  
//
//  Created by Alex da Franca on 14.10.19.
//

import XCTest
@testable import FFSNetwork

class ErrorMessageProviderTests: XCTestCase {
    func testErrorMessageProvider() {
        let mockRequest = URLRequest(url: URL(string: "http://www.farbflash.de")!)
        let mockError = ServerConnectionError.unexpectedResponse
        
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(mockError), "Unexpected Response")
        
        var error = ServerConnectionError.dataDecodingError(mockError, mockRequest, nil, nil)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Error decoding data")
        
        error = .descriptiveServerError("Error description")
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Error description")
        
        error = .httpError(17)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "HTTP Error 17")
        
        error = .httpErrorNotNil(mockError, mockRequest, nil, nil)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Server error")
        
        error = .noHTTPResponse(mockRequest, nil, nil)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "No Server Response")
        
        var urlComps = URLComponents()
        urlComps.scheme = "https"
        urlComps.host = "farbflash.de"
        error = .unableToCreateURLFromComponents(urlComps)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Unable to create url from components: https://farbflash.de")
        
        error = .unableToCreateURLFromString("some string")
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(error), "Unable to create url from string: some string")
        
        let stringResponseError = StringResponseError.unexpectedResponse("Data".data(using: .utf8)!, nil)
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(stringResponseError), "Unexpected Response")
        
        let nsError = NSError(domain: "de.farbflash", code: 17, userInfo: ["description": "Description"])
        XCTAssertEqual(ErrorMessageProvider.errorMessageFor(nsError), "The operation couldn’t be completed. (de.farbflash error 17.)")
    }
}
