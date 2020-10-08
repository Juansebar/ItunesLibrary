//
//  Font.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

enum Fonts {
    case boldTitle
    case text
    
    var font: UIFont {
        switch self {
        case .boldTitle: return UIFont.boldSystemFont(ofSize: 17)
        case .text: return UIFont.systemFont(ofSize: 16)
        }
    }
    
}
