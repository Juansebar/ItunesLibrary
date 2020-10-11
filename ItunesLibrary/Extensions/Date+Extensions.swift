//
//  Date+Extensions.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/10/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import Foundation

extension Date {
    
    static func dayMonthYear(dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: date)
    }
    
}
