//
//  FetchTodosResponse.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation
import FFSNetwork

struct Todo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct FetchTodosResponse: TypedNetworkResponse {
    typealias ResponseType = [Todo]
    
    let value: ResponseType
    let urlResponse: URLResponse?
    let sentRequest: URLRequest
    
    var httpURLResponse: HTTPURLResponse? {
        return urlResponse as? HTTPURLResponse
    }
    
    init(data: Data?, urlResponse: URLResponse?, sentRequest: URLRequest) throws {
        guard let data = data else {
            throw JSONResponseError.noData(urlResponse)
        }
        self.urlResponse = urlResponse
        self.sentRequest = sentRequest
        do {
            let response = try JSONDecoder().decode(ResponseType.self, from: data)
            self.value = response
        }
        catch {
            throw JSONResponseError.decodingError(error, sentRequest, urlResponse, String(data: data, encoding:.utf8))
        }
    }
    
    func jobDetailsAfter(_ elapsedSeconds: Double) -> String {
        let elapsed = formatter.string(from: NSNumber(value: elapsedSeconds)) ?? ""
        return sentRequest.formattedURLRequest + "\n" +
            "\nELAPSED TIME: \(elapsed) seconds...\n" +
            (httpURLResponse?.formattedURLResponse ?? "No response!")
    }
    
    private let formatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 3
        fmt.minimumIntegerDigits = 1
        return fmt
    }()
}

enum JSONResponseError: Error {
    case noData(URLResponse?)
    case decodingError(Error, URLRequest, URLResponse?, String?)
}
