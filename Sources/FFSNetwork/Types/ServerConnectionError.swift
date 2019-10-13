//
//  ServerConnectionError.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public enum ServerConnectionError: Error {
    /// Error is not nil
    case httpErrorNotNil(Error, URLRequest, URLResponse?, Data?)
    
    /// Error which occurred in the last step: decoding the data
    case dataDecodingError(Error, URLRequest, URLResponse?, Data?)
    
    /// Not even an HTTPResponse?
    case noHTTPResponse(URLRequest, URLResponse?, Data?)
    
    /// Typically refers to an internal error; XRequest expects, XResponse.
    case unexpectedResponse

    /// Holds server error messages intended for user presentation.
    case descriptiveServerError(String)

    /// Holds the HTTP Status Code. .descriptiveServerError is
    /// preferred over .httpError when possible.
    case httpError(Int)

    /// Unable to create the URL from string
    case unableToCreateURLFromString(String)
    
    /// Unable to create the URL from URLComponents
    case unableToCreateURLFromComponents(URLComponents)
}
