//
//  RequestHeaderConstants.swift
//  FFSNetwork
//
//  Created by Alex da Franca on 19.01.19.
//  Copyright © 2019 Farbflash. All rights reserved.
//

import Foundation

public struct RequestHeaderConstants {
    public static let TXTApplicationHeader = ["Accept": "text/plain"]
    public static let TXTApplicationHeaderUTF8 = ["Accept": "text/plain; charset=utf-8"]
    public static let HTMLApplicationHeader = ["Accept": "text/html"]
    public static let HTMLApplicationHeaderUTF8 = ["Accept": "text/html; charset=utf-8"]
    public static let JSONApplicationHeader = ["Accept": "application/json"]
}
