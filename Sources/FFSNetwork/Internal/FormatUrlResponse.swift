//
//  FormatUrlResponse.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 28.07.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

internal extension URLResponse {
    func formattedURLResponse(verbose: Bool = false, correlationId: String = "", elapsed: TimeInterval = .zero) -> String {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.formattedHTTPURLResponse(verbose: verbose, correlationId: correlationId, elapsed: elapsed)
        }
        var responseString = ""
        if let url = url {
            responseString += "RESPONSE FROM URL (\(correlationId)): \(url.absoluteString) took \(String(format: "%.3f", elapsed)) seconds"
        }
        if verbose {
            if let mimeType = mimeType { responseString += "\nMIME TYPE: \(mimeType)" }
            if let textEncodingName = textEncodingName { responseString += "\nTEXT ENCODNG NAME: \(textEncodingName)" }
            responseString += "\nEXPECTED CONTENT LENGTH: \(expectedContentLength)"
            if let suggestedFilename = suggestedFilename { responseString += "\nSUGGESTED FILENAME: \(suggestedFilename)" }
        }
        return responseString
    }
}

internal extension HTTPURLResponse {
    func formattedHTTPURLResponse(verbose: Bool = false, correlationId: String = "", elapsed: TimeInterval = .zero) -> String {
        var formattedHeaders: String {
            return allHeaderFields.map({ item -> String in
                let (key, value) = item
                return "\t\(key) = \(value)"
            }).joined(separator: "\n")
        }
        var responseString = ""
        if let url = url {
            responseString += "RESPONSE FROM URL (\(correlationId)): \(url.absoluteString) took \(String(format: "%.3f", elapsed)) seconds"
        }
        if verbose {
            if let mimeType = mimeType { responseString += "\nMIME TYPE: \(mimeType)" }
            if let textEncodingName = textEncodingName { responseString += "\nTEXT ENCODNG NAME: \(textEncodingName)" }
            responseString += "\nEXPECTED CONTENT LENGTH: \(expectedContentLength)"
            if let suggestedFilename = suggestedFilename { responseString += "\nSUGGESTED FILENAME: \(suggestedFilename)" }
            responseString += "\nSTATUS CODE: \(HTTPURLResponse.localizedString(forStatusCode: statusCode)) \(statusCode)"
            responseString += "\nHEADERS:\n\(formattedHeaders)"
        }
        return responseString
    }
}

internal extension URLRequest {
    func formattedURLRequest(verbose: Bool = true, correlationId: String = "") -> String {
        var formattedHeaders: String {
            guard let allHTTPHeaderFields = allHTTPHeaderFields else {
                return ""
            }
            return allHTTPHeaderFields.map({ item -> String in
                let (key, value) = item
                return "\t\(key) = \(value)"
            }).joined(separator: "\n")
        }
        var responseString = ""
        if let httpMethod = httpMethod { responseString += "\(httpMethod) ".uppercased() }
        if let url = url { responseString += "REQUEST TO URL (\(correlationId)): \(url.absoluteString)" }
        if verbose {
            let headers = formattedHeaders
            if headers.isEmpty {responseString += "\nHEADERS:"}
            else {responseString += "\nHEADERS:\n\(headers)"}
            responseString += "\nCACHE POLICY: \(cachePolicy.debugDescription)"
        }
        if let httpBody = httpBody {
            let body = "\(String(data: httpBody, encoding: .utf8) ?? String(data: httpBody, encoding: .isoLatin1) ?? httpBody.description)"
            responseString += "\nBODY:\n\(body)"
        }
        if verbose {
            responseString += "\nTIMEOUT INTERVAL: \(timeoutInterval)"
            responseString += "\nHTTP SHOULD HANDLE COOKIES: \(httpShouldHandleCookies)"
            responseString += "\nHTTP SHOULD USE PIPELINING: \(httpShouldUsePipelining)"
            responseString += "\nALLOWS CELLULAR ACCESS: \(allowsCellularAccess)"
            responseString += "\nNETWORK SERVICE TYPE: \(networkServiceType)"
        }
        return responseString
    }
}

extension NSURLRequest.CachePolicy {
    var debugDescription: String {
        switch self {
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "reloadIgnoringLocalAndRemoteCacheData"
        case .reloadIgnoringLocalCacheData:
            return "reloadIgnoringLocalCacheData"
        case .reloadRevalidatingCacheData:
            return "reloadRevalidatingCacheData"
        case .returnCacheDataDontLoad:
            return "returnCacheDataDontLoad"
        case .returnCacheDataElseLoad:
            return "returnCacheDataElseLoad"
        case .useProtocolCachePolicy:
            return "useProtocolCachePolicy"
        @unknown default:
            return "unknown default"
        }
    }
}
