//
//  ServerConfigurationTests.swift
//  
//
//  Created by Alex da Franca on 14.10.19.
//

import XCTest
@testable import FFSNetwork

class ServerConfigurationTests: XCTestCase {
    func testServerConfigruation() {
        class MockTestConfiguration: ServerConfiguring {
            var urlComponents: URLComponents
            init(urlComponents: URLComponents) {
                self.urlComponents = urlComponents
            }
        }
        
        var componentsWithPort = URLComponents()
        componentsWithPort.scheme = "https"
        componentsWithPort.host = "farbflash.de"
        componentsWithPort.port = 17
        let configWithPort = MockTestConfiguration(urlComponents: componentsWithPort)
        XCTAssertEqual(configWithPort.urlComponents.url?.absoluteString, "https://farbflash.de:17")
        let request = TypedRequest<StringResponse>(path: "/users")
        XCTAssertNoThrow(try configWithPort.createURLRequest(with: request))
        let urlRequest = try! configWithPort.createURLRequest(with: request)
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://farbflash.de:17/users")
        
        let emptyComponents = URLComponents()
        let emptyConfig = MockTestConfiguration(urlComponents: emptyComponents)
        let emptyRequest = Request(path: "")
        XCTAssertThrowsError(try emptyConfig.createURLRequest(with: emptyRequest))
    }
}
