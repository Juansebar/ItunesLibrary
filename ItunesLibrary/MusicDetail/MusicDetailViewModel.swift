//
//  MusicDetailViewModel.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/9/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayerState {
    case neutral
    case playing
    case paused
    case ended
}

protocol MusicDetailViewModelContract {
    
    var artistName: String { get }
    var collectionName: NSAttributedString? { get }
    var trackName: String { get }
    var artwork: Box<UIImage?> { get }
    var collectionPrice: NSAttributedString? { get }
    var trackPrice: NSAttributedString? { get }
    var currency: String { get }
    var releaseDate: NSAttributedString? { get }
    var genre: NSAttributedString? { get }
    
    var playerState: Box<PlayerState> { get set }
    var songProgress: Box<Float> { get }
    var currentTime: Box<String?> { get }
    var duration: Box<String?> { get }
    
    func play()
    func pause()
    func playPause()
    func setSongPreviewDidDownloadClosure(callback: @escaping () -> Void)
    func audioPlayerCurrentTime(_ value: Float)
    
}

class MusicDetailViewModel: NSObject, MusicDetailViewModelContract {
    
    private let song: Song
    
    // MARK: - Song Info
    
    var artistName: String { return song.artistName }
    var trackName: String { return song.trackName }
    var currency: String { return song.currency }
    let artwork: Box<UIImage?> = Box(nil)

    var collectionName: NSAttributedString? {
        return attribute(text: song.collectionName, title: "Album")
    }
    var collectionPrice: NSAttributedString? {
        let formattedPrice = formatPrice(song.collectionPrice, currency: song.currency)
        return attribute(text: formattedPrice, title: "Album Price")
    }
    var trackPrice: NSAttributedString? {
        if song.trackPrice < 0 {
            return nil
        }
        let formattedPrice = formatPrice(song.trackPrice, currency: song.currency)
        return attribute(text: formattedPrice, title: "Song Price")
    }
    var releaseDate: NSAttributedString? {
        let dateString = Date.dayMonthYear(dateString: song.releaseDate)
        return attribute(text: dateString, title: "Released")
    }
    var genre: NSAttributedString? {
        return attribute(text: song.genre, title: "Genre")
    }
    
    // MARK: - AVPlayer
    
    private var audioPlayer: AVPlayer! = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    private var playerItem: AVPlayerItem?
    var playerState: Box<PlayerState> = Box(.neutral)
    let currentTime: Box<String?> = Box("00:00")
    let duration: Box<String?> = Box("--:--")
    let songProgress: Box<Float> = Box(0)
    
    private var songPreviewDidDownload: (() -> Void)?
    
   
    // MARK: - Init
    
    init(_ song: Song) {
        self.song = song
        super.init()
        
        fetchArtwork()
    }
    
    deinit {
        guard let playerItem = self.playerItem else { return }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func fetchArtwork() {
        let artworkUrl = song.artworkUrl100
        
        guard let url = URL(string: artworkUrl) else { return }
        ImageCache.publicCache.load(url: url) { (result) in
            switch result {
            case .success(let image):
                self.artwork.value = image
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchPreview() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let urlString = self?.song.previewUrl, let previewUrl = URL(string: urlString) else { return }

            let playerItem = AVPlayerItem(url: previewUrl)
            self?.playerItem = playerItem
            self?.audioPlayer.replaceCurrentItem(with: playerItem)
            self?.observeAudioPlayerCurrentTime()
            
            DispatchQueue.main.async { [weak self] in
                self?.songPreviewDidDownload?()
            }
            
            guard self != nil else { return }
            NotificationCenter.default.addObserver(self!, selector: #selector(self?.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
    
    func setSongPreviewDidDownloadClosure(callback: @escaping () -> Void) {
        songPreviewDidDownload = callback
        fetchPreview()
    }
    
    // MARK: - AVPlayer Functions
    
    func play() {
        audioPlayer.play()
    }
    
    func playPause() {
        switch audioPlayer.timeControlStatus {
        case .paused: audioPlayer.play()
        case .playing: audioPlayer.pause()
        default: break
        }
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    // MARK: - AVPlayer Time Observer
    
    private func observeAudioPlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        audioPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
            self?.currentTime.value = time.formatTimeMinuteSecond()
            self?.duration.value = self?.audioPlayer.currentItem?.duration.formatTimeMinuteSecond()
            
            self?.updateCurrentTime()
        })
    }
    
    private func updateCurrentTime() {
        let currentTimeSeconds = CMTimeGetSeconds(audioPlayer.currentTime())
        let durationSeconds = CMTimeGetSeconds(audioPlayer.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        
        let percentage = Float(currentTimeSeconds / durationSeconds)
        
        songProgress.value = percentage
    }
    
    func audioPlayerCurrentTime(_ percentage: Float) {
        guard let duration = audioPlayer.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        
        audioPlayer.seek(to: seekTime)
    }
    
    @objc private func playerDidFinishPlaying() {
        playerState.value = .ended
        audioPlayerCurrentTime(0)
    }
    
    // MARK: - String/Attributed Formatter
    
    private func attribute(text: String, title: String) -> NSAttributedString {
        let mutatingString = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : Fonts.mediumBoldTitle.font, NSAttributedString.Key.foregroundColor: UIColor.black])
        
        mutatingString.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 2)]))
        mutatingString.append(NSAttributedString(string: "    " + text, attributes: [NSAttributedString.Key.font : Fonts.text.font, NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        return mutatingString
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let currencySymbol = Currency(rawValue: currency)?.symbol ?? Currency.USD.symbol
        let price = max(price, 0)
        
        return price > 0 ? "\(currencySymbol)\(price)" : ""
    }
    
}
