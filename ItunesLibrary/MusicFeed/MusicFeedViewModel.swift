//
//  MusicFeedViewModel.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import Foundation

protocol MusicFeedViewModelContract {
    var songs: [Song] { get set }
    
    func setSongsDidChange(callback: @escaping () -> Void) -> Void
    func fetchMusic(with searchTerm: String)
}

class MusicFeedViewModel: MusicFeedViewModelContract {
    
    var songs: [Song] = [] {
        didSet {
            songsDidChange?()
        }
    }
    
    private var songsDidChange: (() -> Void)?
    
    init() {
        fetchMusic(with: "Michael Jackson")
    }
    
    func setSongsDidChange(callback: @escaping () -> Void) {
        songsDidChange = callback
    }
    
    func fetchMusic(with searchTerm: String) {
        APIService.fetchItunesMusic(searchTerm: searchTerm) { (result) in
            switch result {
            case .success(let songs):
                self.songs = songs
            case .failure(let error):
                // Handle error
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchMusic() {
        
    }
    
}
