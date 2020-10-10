//
//  Font.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

enum Fonts {
    case largeBoldTitle
    case mediumBoldTitle
    case largeText
    case text
    
    var font: UIFont {
        switch self {
        case .largeBoldTitle: return UIFont.boldSystemFont(ofSize: 24)
        case .mediumBoldTitle: return UIFont.boldSystemFont(ofSize: 17)
        case .largeText: return UIFont.systemFont(ofSize: 20)
        case .text: return UIFont.systemFont(ofSize: 16)
        }
    }
    
}
