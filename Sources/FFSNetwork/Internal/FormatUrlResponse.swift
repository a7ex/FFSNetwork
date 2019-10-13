//
//  FormatUrlResponse.swift
//  NetworkStack
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

internal extension URLResponse {
    var formattedURLResponse: String {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.formattedHTTPURLResponse
        }
        var responseString = "-----------------------------"
        if let url = url { responseString += "\nRESPONSE FROM URL: \(url.absoluteString)" }
        if let mimeType = mimeType { responseString += "\nMIME TYPE: \(mimeType)" }
        if let textEncodingName = textEncodingName { responseString += "\nTEXT ENCODNG NAME: \(textEncodingName)" }
        responseString += "\nEXPECTED CONTENT LENGTH: \(expectedContentLength)"
        if let suggestedFilename = suggestedFilename { responseString += "\nSUGGESTED FILENAME: \(suggestedFilename)" }
        responseString += "\n-----------------------------"
        return responseString
    }
}

internal extension HTTPURLResponse {
    var formattedHTTPURLResponse: String {
        var formattedHeaders: String {
            return allHeaderFields.map({ item -> String in
                let (key, value) = item
                return "\t\(key) = \(value)"
            }).joined(separator: "\n")
        }
        var responseString = "-----------------------------"
        if let url = url { responseString += "\nRESPONSE FROM URL: \(url.absoluteString)" }
        if let mimeType = mimeType { responseString += "\nMIME TYPE: \(mimeType)" }
        if let textEncodingName = textEncodingName { responseString += "\nTEXT ENCODNG NAME: \(textEncodingName)" }
        responseString += "\nEXPECTED CONTENT LENGTH: \(expectedContentLength)"
        if let suggestedFilename = suggestedFilename { responseString += "\nSUGGESTED FILENAME: \(suggestedFilename)" }
        responseString += "\nSTATUS CODE: \(HTTPURLResponse.localizedString(forStatusCode: statusCode)) \(statusCode)"
        responseString += "\nHEADERS:\n\(formattedHeaders)"
        responseString += "\n-----------------------------"
        return responseString
    }
}

internal extension URLRequest {
    var formattedURLRequest: String {
        var formattedHeaders: String {
            guard let allHTTPHeaderFields = allHTTPHeaderFields else {
                return ""
            }
            return allHTTPHeaderFields.map({ item -> String in
                let (key, value) = item
                return "\t\(key) = \(value)"
                }).joined(separator: "\n")
        }
        var responseString = "-----------------------------"
        if let url = url { responseString += "\nREQUEST TO URL: \(url.absoluteString)" }
        if let httpMethod = httpMethod { responseString += "\nMETHOD: \(httpMethod)" }
        let headers = formattedHeaders
        if headers.isEmpty {responseString += "\nHEADERS:"}
        else {responseString += "\nHEADERS:\n\(headers)"}
        responseString += "\nCACHE POLICY: \(cachePolicy)"
        if let httpBody = httpBody { responseString += "\nBODY:\n\(String(data: httpBody, encoding: .utf8) ?? String(data: httpBody, encoding: .isoLatin1) ?? httpBody.description)" }
        responseString += "\nTIMEOUT INTERVAL: \(timeoutInterval)"
        responseString += "\nHTTP SHOULD HANDLE COOKIES: \(httpShouldHandleCookies)"
        responseString += "\nHTTP SHOULD USE PIPELINING: \(httpShouldUsePipelining)"
        responseString += "\nALLOWS CELLULAR ACCESS: \(allowsCellularAccess)"
        responseString += "\nNETWORK SERVICE TYPE: \(networkServiceType)"
        responseString += "\n-----------------------------"
        return responseString
    }
}
