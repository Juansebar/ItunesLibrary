//
//  MusicDetailViewController.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/9/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit
import AVFoundation

class MusicDetailViewController: UIViewController {
    
    private let viewModel: MusicDetailViewModelContract
    
    private var audioPlayer: AVAudioPlayer?
    
    private enum PlayerState {
        case neutral
        case playing
        case paused
        case ended
    }
    
    private enum PlayerFunction {
        case play
        case stop
        case timer
        case drag
    }
    
    private var playerState: PlayerState = .neutral {
        didSet {
            //            if Common.showStatus {
            //                status.text = "." + String(describing: playerState)
            //            }
        }
    }
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(playEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(stopEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progress: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = UIColor.cyan //Colors.karyn.color
        slider.thumbTintColor = Colors.lightGray.color
        slider.addTarget(self, action: #selector(progressDidChange), for: .valueChanged)
        return slider
    }()
    
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.lightGray.color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow //Colors.white.color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cardView: CardView = {
        let cardView = CardView(cardViews: (frontView: self.artworkImageView, backView: self.infoView))
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true
        cardView.layer.shadowColor = UIColor.init(white: 0, alpha: 0.9).cgColor
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.font = Fonts.largeBoldTitle.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.largeText.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = Fonts.text.font
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.largeText.font
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.largeText.font
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.largeText.font
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackLabelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.songNameLabel, self.artistNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var additionInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.albumNameLabel, self.genreLabel, self.releaseDateLabel, self.priceLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(viewModel: MusicDetailViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.white.color
        
        setupViews()
        setupConstraints()
        
//        setupPlayer()
        
        viewModel.artwork.bind { [weak self] (image) in
            self?.artworkImageView.image = image
        }
        
        disallow()
        playerState = .neutral
        viewModel.setSongPreviewDidDownloadClosure { [weak self] (player) in
            self?.audioPlayer = player
            self?.audioPlayer?.numberOfLoops = 0
            self?.audioPlayer?.delegate = self
            self?.audioPlayer?.prepareToPlay()
            
            guard let end = self?.audioPlayer?.duration else { return }
            self?.allow()
        }
        
        songNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        albumNameLabel.attributedText = viewModel.collectionName
        releaseDateLabel.attributedText = viewModel.releaseDate
        genreLabel.attributedText = viewModel.genre
        priceLabel.attributedText = viewModel.trackPrice
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
    }
    
//    private func setupPlayer() {
//        disallow()
//        do {
//            audioPlayer = try AVAudioPlayer(data: Data(contentsOf: viewModel.previewUrl))
//            audioPlayer?.numberOfLoops = 0
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//
//            guard let end = audioPlayer?.duration else { return }
//            allow()
//        } catch {
//            // Show some alert
//            print(error.localizedDescription)
//        }
//    }
    
    func setupViews() {
        view.addSubview(cardView)
        view.addSubview(trackLabelsStackView)
        view.addSubview(playButton)
        view.addSubview(progress)
        
        infoView.addSubview(additionInfoStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.heightAnchor.constraint(equalToConstant: min(view.frame.width, view.frame.height) * 2/3),
            cardView.widthAnchor.constraint(equalTo: cardView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            trackLabelsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            trackLabelsStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 40),
            trackLabelsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
        ])
        
        NSLayoutConstraint.activate([
            additionInfoStackView.leftAnchor.constraint(equalTo: infoView.leftAnchor, constant: 10),
            additionInfoStackView.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 10),
            additionInfoStackView.rightAnchor.constraint(equalTo: infoView.rightAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
//        NSLayoutConstraint.activate([
//            progress.leftAnchor.constraint(equalTo: additionInfoStackView.leftAnchor),
//            progress.rightAnchor.constraint(equalTo: additionInfoStackView.rightAnchor),
//            progress.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -10)
//        ])
    }
    
    // MARK: - Local routines
    
    @objc private func timerFired() { timerEvent() }
    
    @objc private func progressDidChange() { dragEvent() }
    
    @objc private func playEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false
        switch playerState {
        case .neutral:
            audioPlayer!.currentTime = 0.00
            play()
            playerState = .playing
            playButton.isEnabled = true
            stopButton.isEnabled = true
        case .playing:
//            timer.invalidate()
            audioPlayer?.pause()
            playButton.setImage(UIImage(named: "play"), for: .normal)
            playButton.isEnabled = true
            stopButton.isEnabled = true
            playerState = .paused
        case .paused:
            play()
            playButton.isEnabled = true
            stopButton.isEnabled = true
            playerState = .playing
        case .ended: break
        }
    }
    
    private func play() {
        audioPlayer!.play()
//        timer.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        playButton.setImage(UIImage(named: "pause"), for: .normal)
    }
    
    @objc private func stopEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false
        switch playerState {
        case .neutral, .ended: break
        case .playing, .paused:
//            timer.invalidate()
            progress.value = Float(0.00)
//            start.set(0.00)
            audioPlayer!.stop()
            playButton.setImage(UIImage(named: "play"), for: .normal)
            playButton.isEnabled = true
            playerState = .neutral
        }
    }
    
    private func timerEvent() {
        progress.value = Float(audioPlayer!.currentTime / audioPlayer!.duration)
//        start.set(audioPlayer!.currentTime)
//        duration.set(audioPlayer!.duration - audioPlayer!.currentTime)
    }
    
    private func dragEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false
        switch playerState {
        case .neutral, .paused, .playing:
//            timer.isPaused = true
            audioPlayer!.currentTime = audioPlayer!.duration * Double(progress.value)
//            start.set(player!.currentTime)
//            timer.isPaused = false
            playButton.isEnabled = true
            stopButton.isEnabled = true
            playerState = .paused
        case .ended: break
        }
    }
    
}

// MARK: - XongViewType

extension MusicDetailViewController {
    
    private func disallow() {
//        spinner.isHidden = false
//        spinner.startAnimating()
        progress.isEnabled = false
        progress.isUserInteractionEnabled = false
        playButton.isEnabled = false
        playButton.isUserInteractionEnabled = false
        stopButton.isEnabled = false
        stopButton.isUserInteractionEnabled = false
    }
    
    private func allow() {
//        spinner.stopAnimating()
//        spinner.isHidden = true
        progress.isEnabled = true
        progress.isUserInteractionEnabled = true
        playButton.isEnabled = true
        playButton.isUserInteractionEnabled = true
        stopButton.isEnabled = true
        stopButton.isUserInteractionEnabled = true
    }
    
}

extension MusicDetailViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if playerState == .playing {
            playerState = .ended
        }
    }
    
}
