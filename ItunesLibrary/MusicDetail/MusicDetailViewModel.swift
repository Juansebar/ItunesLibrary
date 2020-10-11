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
    var playerState: Box<PlayerState> { get set }
    
    var timer: CADisplayLink? { get }
    var songProgress: Box<Float> { get }
    var currentTime: Box<String?> { get }
    var duration: Box<String?> { get }
    
    var artistName: String { get }
    var collectionName: NSAttributedString? { get }
    var trackName: String { get }
    var artwork: Box<UIImage?> { get }
    var collectionPrice: NSAttributedString? { get }
    var trackPrice: NSAttributedString? { get }
    var currency: String { get }
    var releaseDate: NSAttributedString? { get }
    var trackTime: String { get }
    var genre: NSAttributedString? { get }
    
    func setSongPreviewDidDownloadClosure(callback: @escaping () -> Void)
    func play()
    func stop()
    func audioPlayerCurrentTime(_ value: Float)
    func handlePlayEvent()
    func handleStopEvent()
    
    func playPause()
    
}

class MusicDetailViewModel: NSObject, MusicDetailViewModelContract {
    let song: Song
    
    var artistName: String { return song.artistName }
    var trackName: String { return song.trackName }
    var currency: String { return song.currency }
    var trackTime: String {
        let totalSeconds = song.trackTimeMillis / 1000
        
        let minutes = Double(totalSeconds / 60).rounded(.down)
        let seconds = totalSeconds % 60
        
        return "\(Int(minutes)):\(seconds)"
        
    }
    let currentTime: Box<String?> = Box("00:00")
    let duration: Box<String?> = Box("--:--")
    
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
        let dateString = Date.dayMonthYear(dateString: song.releaseDate)
        return attribute(text: dateString, title: "Released")
    }
    var genre: NSAttributedString? {
        return attribute(text: song.genre, title: "Genre")
    }
    
    var timer: CADisplayLink?
    
    let songProgress: Box<Float> = Box(0)
    
//    var playerState: PlayerState = .neutral {
//            didSet {
//                switch playerState {
//                case .neutral:
//                    audioPlayer?.currentTime = 0.00
//                    play()
//                case .playing:
//                    stop()
//    //                audioPlayer?.pause()
//                case .paused:
//                    play()
//                case .ended: break
//                }
//            }
//        }
    
    var playerState: Box<PlayerState> = Box(.neutral) // {
//        didSet {
//            switch playerState {
//            case .neutral:
//                audioPlayer?.currentTime = 0.00
////                play()
//            case .playing:
////                stop()
////                audioPlayer?.pause()
//            case .paused:
////                play()
//            case .ended: break
//            }
//        }
//    }
    
    deinit {
        print("MusicDetailViewModel - deinit")
    }
    
    init(_ song: Song) {
        self.song = song
        super.init()
        
        
        fetchArtwork()
//        fetchPreview()
    }
    
    private var songPreviewDidDownload: (() -> Void)?
    
    func setSongPreviewDidDownloadClosure(callback: @escaping () -> Void) {
        songPreviewDidDownload = callback
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
    
    private var audioPlayer: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    private func fetchPreview() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let urlString = self?.song.previewUrl, let previewUrl = URL(string: urlString) else { return }

            let playerItem = AVPlayerItem(url: previewUrl)
            self?.audioPlayer.replaceCurrentItem(with: playerItem)
            
//            let timer = CMTimeMake(value: 1, timescale: 3)
//            let times = [NSValue(time: timer)]
//                
//            self?.audioPlayer.addBoundaryTimeObserver(forTimes: times, queue: .main, using: {
//                print("Episode started playing")
//            })
            
            self?.observeAudioPlayerCurrentTime()
            
            DispatchQueue.main.async { [weak self] in
                self?.songPreviewDidDownload?()
            }
        }
    }
    
    func play() {
        timer = CADisplayLink(target: self, selector: #selector(timerFired))
        timer?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        audioPlayer.play()
    }
    
    func stop() {
//        audioPlayer.stop()
    }
    
    func playPause() {
        if audioPlayer.timeControlStatus == .paused {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    func pause() {
        if audioPlayer.timeControlStatus == .paused {
            return
        } else {
            
        }
        audioPlayer.pause()
    }
    
    func handlePlayEvent() {
        switch playerState.value {
        case .neutral:
            playerState.value = .playing
//            audioPlayer.currentTime = 0.00
            
            //                    viewModel.audioPlayerCurrentTime(0)
            play()
//                        playerState = .playing
            
        case .playing:
            //            timer.invalidate()
            //            audioPlayer?.pause()
            pause()
            playerState.value = .paused
        case .paused:
            playerState.value = .playing
            play()
        //            playerState = .playing
        case .ended: break
        }
    }
    
    func handleStopEvent() {
        switch playerState.value {
        case .neutral, .ended: break
        case .playing, .paused:
            timer?.invalidate()
            //            timer.invalidate()
            //                    progress.value = Float(0.00)
            //            start.set(0.00)
            stop()
            //            audioPlayer!.stop()
            playerState.value = .neutral
        }
    }
    
    @objc func timerFired() {
        timerEvent()
    }
    
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
    
    private func timerEvent() {
//        songProgress.value = Float(audioPlayer!.currentTime / audioPlayer!.duration)
        
//        start.set(audioPlayer!.currentTime)
//        duration.set(audioPlayer!.duration - audioPlayer!.currentTime)
    }
    
    func audioPlayerCurrentTime(_ value: Float) {
//        guard audioPlayer != nil else { return }
//        audioPlayer?.pause()
//        playerState.value = .paused
//        audioPlayer?.currentTime = audioPlayer!.duration * Double(value)
//        audioPlayer?.play()
    }
    
    private func formatTime(string: String) -> String {
        
        return string
    }
    
    private func attribute(text: String, title: String) -> NSAttributedString {
        let mutatingString = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : Fonts.mediumBoldTitle.font, NSAttributedString.Key.foregroundColor: UIColor.black])
        
        mutatingString.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 2)]))
        mutatingString.append(NSAttributedString(string: "  " + text, attributes: [NSAttributedString.Key.font : Fonts.text.font, NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        return mutatingString
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let currencySymbol = Currency(rawValue: currency)?.symbol ?? Currency.USD.symbol
        let price = max(price, 0)
        
        return price > 0 ? "\(currencySymbol)\(price)" : ""
    }
    
}

extension MusicDetailViewModel: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio ended - \(playerState.value)")
        if playerState.value == .playing {
            playerState.value = .ended
        }
    }
    
}
