//
//  FormatUrlResponse.swift
//  NetworkStack
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

internal extension URLResponse {
    var formattedString: String {
        var allHeaderFields = [AnyHashable: Any]()
        var statusCode = ""
        if let httpResponse = self as? HTTPURLResponse {
            statusCode = "\(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)) (\(httpResponse.statusCode))"
            allHeaderFields = httpResponse.allHeaderFields
        }
        return """
        -----------------------------
        RECEIVED ARRAY OF TODOS FROM: \(url?.absoluteString ?? "")
        MIME TYPE: \(mimeType ?? "")
        TEXT ENCODNG NAME: \(textEncodingName ?? "")
        STATUS CODE: \(statusCode)
        HEADERS: \(allHeaderFields as AnyObject)
        """
    }
}

internal extension URLRequest {
    var formattedString: String {
        return """
        -----------------------------
        REQUESTED ARRAY OF TODOS FROM: \(url?.absoluteString ?? "")
        METHOD: \(httpMethod ?? "")
        HEADERS: \(allHTTPHeaderFields as AnyObject)
        """
    }
}
