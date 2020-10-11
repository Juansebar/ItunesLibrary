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
    
    var artistName: String { get }
    var collectionName: NSAttributedString? { get }
    var trackName: String { get }
    var artwork: Box<UIImage?> { get }
    var collectionPrice: NSAttributedString? { get }
    var trackPrice: NSAttributedString? { get }
    var currency: String { get }
    var releaseDate: NSAttributedString? { get }
    var trackTimeMillis: Int { get }
    var genre: NSAttributedString? { get }
    
    func setSongPreviewDidDownloadClosure(callback: @escaping (AVAudioPlayer) -> Void)
    func play()
    func stop()
    func audioPlayerCurrentTime(_ value: Float)
    func handlePlayEvent()
    func handleStopEvent()
    
    
}

class MusicDetailViewModel: NSObject, MusicDetailViewModelContract {
    let song: Song
    
    var artistName: String { return song.artistName }
    var trackName: String { return song.trackName }
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
    
    init(_ song: Song) {
        self.song = song
        super.init()
        
        
        fetchArtwork()
//        fetchPreview()
    }
    
    private var songPreviewDidDownload: ((AVAudioPlayer) -> Void)?
    
    func setSongPreviewDidDownloadClosure(callback: @escaping (AVAudioPlayer) -> Void) {
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
    
    private var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let player = audioPlayer else { return }
            songPreviewDidDownload?(player)
        }
    }
    
    private func fetchPreview() {
        DispatchQueue.global(qos: .userInitiated).async {
            let previewUrl = URL(string: self.song.previewUrl)!
            do {
                let player = try AVAudioPlayer(data: Data(contentsOf: previewUrl))
                player.numberOfLoops = 0
                player.delegate = self
                player.prepareToPlay()
                DispatchQueue.main.async {
                    self.audioPlayer = player
                }
            } catch {
                print("This is an error:" + error.localizedDescription)
            }
        }
    }
    
    func play() {
        timer = CADisplayLink(target: self, selector: #selector(timerFired))
        timer?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        audioPlayer!.play()
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func handlePlayEvent() {
        switch playerState.value {
        case .neutral:
            playerState.value = .playing
            audioPlayer!.currentTime = 0.00
            //                    viewModel.audioPlayerCurrentTime(0)
            play()
            //            playerState = .playing
            
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
    
    private func timerEvent() {
        songProgress.value = Float(audioPlayer!.currentTime / audioPlayer!.duration)
//        start.set(audioPlayer!.currentTime)
//        duration.set(audioPlayer!.duration - audioPlayer!.currentTime)
    }
    
    func audioPlayerCurrentTime(_ value: Float) {
        guard audioPlayer != nil else { return }
        audioPlayer?.pause()
        playerState.value = .paused
        audioPlayer?.currentTime = audioPlayer!.duration * Double(value)
//        audioPlayer?.play()
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

extension MusicDetailViewModel: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio ended - \(playerState.value)")
        if playerState.value == .playing {
            playerState.value = .ended
        }
    }
    
}
