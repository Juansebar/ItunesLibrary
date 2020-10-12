//
//  CMTime+Extensions.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/11/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import AVKit

extension CMTime {
    
    func formatTimeMinuteSecond() -> String? {
        if self == .invalid || self == .indefinite || self == .positiveInfinity {
            return nil
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
