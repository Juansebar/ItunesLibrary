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
    
    private let cardViewScaleTransform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    
    deinit {
        print("MusicDetailViewController - deinit")
    }

    
    private enum PlayerState {
        case neutral
        case playing
        case paused
        case ended
    }
    
    private lazy var playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.delegate = self
        playerView.isUserInteractionEnabled = true
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.lightGray.color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var cardView: CardView = {
        let cardView = CardView(cardViews: (frontView: self.artworkImageView, backView: self.infoView))
        cardView.layer.shadowColor = Colors.lightGray.color.cgColor
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.8
        cardView.layer.shadowOffset = .init(width: 0, height: 5)
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
            self?.infoView.image = image
        }
        
        playerView.disallow()
        viewModel.setSongPreviewDidDownloadClosure { [weak self] in
            self?.playerView.allow()
        }
        
        viewModel.songProgress.bind { [weak self] (progress) in
            self?.playerView.currentTimeSlider.value = progress
        }
        
        viewModel.currentTime.bind { [weak self] (timeString) in
            self?.playerView.currentTimeLabel.text = timeString
        }
        
        viewModel.duration.bind { [weak self] (timeString) in
            self?.playerView.durationLabel.text = timeString
        }
        
        viewModel.playerState.bind { [weak self] (state) in
            if state == .ended {
                self?.playerView.setPlayPauseButton(to: .play)
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
        viewModel.pause()
    }
    
    func setupViews() {
        view.addSubview(cardView)
        view.addSubview(trackLabelsStackView)
        view.addSubview(playerView)
        
        infoView.addSubview(additionInfoStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            cardView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 25),
//            cardView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25),
//            cardView.heightAnchor.constraint(equalTo: cardView.widthAnchor),
            cardView.heightAnchor.constraint(equalToConstant: min(view.frame.width, view.frame.height) * 3/4),
            cardView.widthAnchor.constraint(equalTo: cardView.heightAnchor)
        ])
        
        cardView.transform = cardViewScaleTransform
        
        NSLayoutConstraint.activate([
            trackLabelsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            trackLabelsStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 15),
            trackLabelsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
        ])
        
        NSLayoutConstraint.activate([
            additionInfoStackView.leftAnchor.constraint(equalTo: infoView.leftAnchor, constant: 10),
            additionInfoStackView.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 10),
            additionInfoStackView.rightAnchor.constraint(equalTo: infoView.rightAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 25),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4),
            playerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            
        ])
    }
    
    // MARK: - Local routines
    
    private func animateCardView(to state: PlayPauseState) {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            if state == .play {
                self.cardView.transform = .identity
            } else {
                self.cardView.transform = self.cardViewScaleTransform
            }
        })
    }

    private enum PlayPauseState {
        case play
        case pause
    }

}

// MARK: - PlayerViewDelegate

extension MusicDetailViewController: PlayerViewDelegate {

    func didTapPlayPauseButton() {
        playerView.playPauseButton.isEnabled = false
        
        viewModel.playPause()
        
        switch viewModel.playerState.value {
        case .neutral:
            viewModel.playerState.value = .playing
            viewModel.audioPlayerCurrentTime(0)
            //            viewModel.play()
            animateCardView(to: .play)
            playerView.setPlayPauseButton(to: .pause)
            playerView.playPauseButton.isEnabled = true
        //            stopButton.isEnabled = true
        case .playing:
            //            viewModel.stop()
            animateCardView(to: .pause)
            playerView.setPlayPauseButton(to: .play)
            playerView.playPauseButton.isEnabled = true
            viewModel.playerState.value = .paused
        case .paused:
            //            viewModel.play()
            animateCardView(to: .play)
            playerView.setPlayPauseButton(to: .pause)
            playerView.playPauseButton.isEnabled = true
            viewModel.playerState.value = .playing
        case .ended: break
        }
    }
    
    func sliderDidChange(value: Float) {
        playerView.playPauseButton.isEnabled = false
        viewModel.audioPlayerCurrentTime(playerView.currentTimeSlider.value)
        
        switch viewModel.playerState.value {
        case .neutral, .paused, .playing:
            playerView.playPauseButton.isEnabled = true
            viewModel.playerState.value = .paused
            playerView.setPlayPauseButton(to: .play)
        case .ended: break
        }
    }
    
}
