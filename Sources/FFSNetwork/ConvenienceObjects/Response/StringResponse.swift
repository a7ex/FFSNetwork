//
//  StringResponse.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 25.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

/// A simple implemantion of a TypedNetworkResponse struct
/// In case of success it contains the contents of the retrieved data as String
/// as well as the HTTPURLResponse (for further information)
public struct StringResponse: TypedNetworkResponse {
    public typealias ResponseType = String
    
    public let value: String
    public let urlResponse: URLResponse?
    public let sentRequest: URLRequest
    
    public var httpURLResponse: HTTPURLResponse? {
        return urlResponse as? HTTPURLResponse
    }
    
    public init(data: Data?, urlResponse: URLResponse?, sentRequest: URLRequest) throws {
        self.urlResponse = urlResponse
        self.sentRequest = sentRequest
        guard let data = data else {
            self.value = ""
            return
        }
        if let str = String(data: data, encoding: .utf8) {
            self.value = str
        } else if let str = String(data: data, encoding: .isoLatin1) {
            self.value = str
        } else {
            throw StringResponseError.unexpectedResponse(data, urlResponse)
        }
    }
}

public enum StringResponseError: Error {
    case unexpectedResponse(Data, URLResponse?)
}

