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
    case white
    
    var color: UIColor {
        switch self {
        case .lightGray: return .init(white: 0.8, alpha: 1)
        case .white: return UIColor.white
        }
    }
}
