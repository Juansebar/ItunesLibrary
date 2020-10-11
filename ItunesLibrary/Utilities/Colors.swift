//
//  Colors.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

enum Colors {
    case lightGray
    case mediumGray
    case red
    case white
    
    var color: UIColor {
        switch self {
        case .lightGray: return UIColor.lightGray
        case .mediumGray: return .init(white: 0.8, alpha: 1)
        case .red: return UIColor.systemRed
        case .white: return UIColor.white
        }
    }
}
