//
//  ErrorMessageProvider.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct ErrorMessageProvider {
    public static func errorMessageFor(_ error: Error) -> String {
        if let convertingError = error as? StringResponseError {
            return errorMessageForError(convertingError)
        }
        if let serverConnectionError = error as? ServerConnectionError {
            return errorMessageForServerConnectionError(serverConnectionError)
        }
        return error.localizedDescription
    }
    private static func errorMessageForServerConnectionError(_ error: ServerConnectionError)
        -> String {
            return error.errorDescription ?? "Unknown error"
    }
    private static func errorMessageForError(_ error: StringResponseError)
        -> String {
            switch error {
            case .unexpectedResponse:
                return "Unexpected Response"
            }
    }
}
