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
    
    private var viewModel: MusicDetailViewModelContract
    
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
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play"), for: .normal)
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
    
    private lazy var progress: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = UIColor.cyan //Colors.karyn.color
        slider.thumbTintColor = Colors.white.color
        slider.addTarget(self, action: #selector(progressDidChange), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
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
        
        viewModel.artwork.bind { [weak self] (image) in
            self?.artworkImageView.image = image
        }
        
        disallow()
        viewModel.setSongPreviewDidDownloadClosure { [weak self] (player) in
            self?.allow()
        }
        
        viewModel.songProgress.bind { [weak self] (progress) in
            self?.progress.value = progress
        }
        
        viewModel.playerState.bind { [weak self] (state) in
            if state == .ended {
                self?.setPlayButton(to: .play)
                self?.viewModel.playerState.value = .neutral
            }
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
        viewModel.stop()
    }
    
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
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            progress.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            progress.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            progress.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -10),
            progress.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Local routines
    
    @objc private func progressDidChange() { dragEvent() }
    
    @objc private func playEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false
        
        switch viewModel.playerState.value {
        case .neutral:
            viewModel.playerState.value = .playing
            viewModel.audioPlayerCurrentTime(0)
            viewModel.play()
            setPlayButton(to: .pause)
            playButton.isEnabled = true
            stopButton.isEnabled = true
        case .playing:
            viewModel.timer?.invalidate()
            viewModel.stop()
            setPlayButton(to: .play)
            playButton.isEnabled = true
            stopButton.isEnabled = true
            viewModel.playerState.value = .paused
        case .paused:
            viewModel.play()
            setPlayButton(to: .pause)
            playButton.isEnabled = true
            stopButton.isEnabled = true
            viewModel.playerState.value = .playing
        case .ended: break
        }
    }
    
    @objc private func stopEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false

        switch viewModel.playerState.value {
        case .neutral, .ended: break
        case .playing, .paused:
            viewModel.timer?.invalidate()
            progress.value = Float(0.00)
            viewModel.stop()
            setPlayButton(to: .play)
            playButton.isEnabled = true
            viewModel.playerState.value = .neutral
        }
    }
    
    private enum PlayButton {
        case play
        case pause
    }
    
    private func setPlayButton(to state: PlayButton) {
        let imageName = state == .play ? "play" : "pause"
        playButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private func dragEvent() {
        playButton.isEnabled = false
        stopButton.isEnabled = false
        switch viewModel.playerState.value {
        case .neutral, .paused, .playing:
            viewModel.timer?.isPaused = true
            viewModel.audioPlayerCurrentTime(progress.value)
            viewModel.timer?.isPaused = false
            playButton.isEnabled = true
            stopButton.isEnabled = true
            viewModel.playerState.value = .paused
            setPlayButton(to: .play)
        case .ended: break
        }
    }
    
}


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
        setPlayButton(to: .play)
        stopButton.isEnabled = true
        stopButton.isUserInteractionEnabled = true
    }
    
}
