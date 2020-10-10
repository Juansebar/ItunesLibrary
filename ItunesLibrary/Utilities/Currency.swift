//
//  Currency.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/10/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import Foundation

enum Currency: String {
    case USD
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        }
    }
}
