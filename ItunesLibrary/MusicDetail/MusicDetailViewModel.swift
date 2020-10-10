//
//  MusicDetailViewModel.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/9/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit
import AVFoundation

protocol MusicDetailViewModelContract {
    var artistName: String { get }
    var collectionName: NSAttributedString? { get }
    var trackName: String { get }
//    var preview: Box<AVAudioPlayer?> { get }
    var previewUrl: URL { get }
    var artwork: Box<UIImage?> { get }
    var collectionPrice: NSAttributedString? { get }
    var trackPrice: NSAttributedString? { get }
    var currency: String { get }
    var releaseDate: NSAttributedString? { get }
    var trackTimeMillis: Int { get }
    var genre: NSAttributedString? { get }
}

class MusicDetailViewModel: MusicDetailViewModelContract {
    let song: Song
    
    var artistName: String { return song.artistName }
    var trackName: String { return song.trackName }
//    let preview: Box<AVAudioPlayer?> = Box(nil)
    var previewUrl: URL {
        return URL(string: song.previewUrl)!
    }
    
    
    var currency: String { return song.currency }
    
    var trackTimeMillis: Int { return song.trackTimeMillis }
    
    let artwork: Box<UIImage?> = Box(nil)

    var collectionName: NSAttributedString? {
        return attribute(text: song.collectionName, title: "Album")
    }
    var collectionPrice: NSAttributedString? {
        let formattedPrice = formatPrice(song.collectionPrice, currency: song.currency)
        return attribute(text: formattedPrice, title: "Album Price")
    }
    var trackPrice: NSAttributedString? {
        let formattedPrice = formatPrice(song.trackPrice, currency: song.currency)
        return attribute(text: formattedPrice, title: "Song Price")
    }
    var releaseDate: NSAttributedString? {
        return attribute(text: song.releaseDate, title: "Released")
    }
    var genre: NSAttributedString? {
        return attribute(text: song.genre, title: "Genre")
    }
    
    init(_ song: Song) {
        self.song = song
        
        fetchArtwork()
        fetchPreview()
    }
    
    private func fetchArtwork() {
        let artworkUrl = song.artworkUrl100
        
        guard let url = URL(string: artworkUrl) else { return }
        ImageCache.publicCache.load(url: url) { (result) in
            switch result {
            case .success(let image):
                self.artwork.value = image
            case .failure(let error):
                // handle error
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchPreview() {
        let previewUrl = URL(string: song.previewUrl)!
        
        do {
            
        } 
    }
    
    private let dateFormatter = DateFormatter()
    
    private func formatTime(string: String) -> String {
        
        return string
    }
    
    private func attribute(text: String, title: String) -> NSAttributedString {
        let mutatingString = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : Fonts.mediumBoldTitle.font, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        mutatingString.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
        mutatingString.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : Fonts.text.font, NSAttributedString.Key.foregroundColor: Colors.lightGray.color]))
        
        return mutatingString
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let currencySymbol = Currency(rawValue: currency)?.symbol ?? Currency.USD.symbol
        let price = max(price, 0)
        
        return price > 0 ? "\(currencySymbol)\(price)" : "Free"
    }
    
}
