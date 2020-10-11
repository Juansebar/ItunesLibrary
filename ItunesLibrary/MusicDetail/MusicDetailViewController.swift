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
    
    private enum PlayerFunction {
        case play
        case stop
        case timer
        case drag
    }
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(playPauseEvent), for: .touchUpInside)
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

    private lazy var currentTimeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = UIColor.systemRed //Colors.karyn.color
        slider.thumbTintColor = Colors.white.color
        slider.addTarget(self, action: #selector(progressDidChange), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.text.font
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = Fonts.text.font
        label.text = "--:--"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
//        cardView.layer.cornerRadius = 5
//        cardView.layer.masksToBounds = false
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
//        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupViews()
        setupConstraints()
        
        viewModel.artwork.bind { [weak self] (image) in
            self?.artworkImageView.image = image
            self?.infoView.image = image
        }
        
        disallow()
        viewModel.setSongPreviewDidDownloadClosure { [weak self] in
            self?.allow()
        }
        
        viewModel.songProgress.bind { [weak self] (progress) in
            self?.currentTimeSlider.value = progress
        }
        
        viewModel.currentTime.bind { [weak self] (timeString) in
            self?.currentTimeLabel.text = timeString
        }
        
        viewModel.duration.bind { [weak self] (timeString) in
            self?.durationLabel.text = timeString
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }
    
    func setupViews() {
        view.addSubview(cardView)
        view.addSubview(trackLabelsStackView)
        view.addSubview(playPauseButton)
        view.addSubview(currentTimeSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        
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
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 80),
            playPauseButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            currentTimeSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            currentTimeSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            currentTimeSlider.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            currentTimeLabel.leftAnchor.constraint(equalTo: currentTimeSlider.leftAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: currentTimeSlider.bottomAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            durationLabel.rightAnchor.constraint(equalTo: currentTimeSlider.rightAnchor),
            durationLabel.topAnchor.constraint(equalTo: currentTimeSlider.bottomAnchor, constant: 8)
        ])
        
    }
    
    // MARK: - Local routines
    
    @objc private func progressDidChange() { dragEvent() }

    @objc private func playPauseEvent() {
        playPauseButton.isEnabled = false
        stopButton.isEnabled = false

        viewModel.playPause()
        
        switch viewModel.playerState.value {
        case .neutral:
            viewModel.playerState.value = .playing
            viewModel.audioPlayerCurrentTime(0)
//            viewModel.play()
            animateCardView(to: .play)
            setPlayButton(to: .pause)
            playPauseButton.isEnabled = true
            stopButton.isEnabled = true
        case .playing:
            viewModel.timer?.invalidate()
//            viewModel.stop()
            animateCardView(to: .pause)
            setPlayButton(to: .play)
            playPauseButton.isEnabled = true
            stopButton.isEnabled = true
            viewModel.playerState.value = .paused
        case .paused:
//            viewModel.play()
            animateCardView(to: .play)
            setPlayButton(to: .pause)
            playPauseButton.isEnabled = true
            stopButton.isEnabled = true
            viewModel.playerState.value = .playing
        case .ended: break
        }
    }
    
    private func animateCardView(to state: PlayPauseState) {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            if state == .play {
                self.cardView.transform = .identity
            } else {
                self.cardView.transform = self.cardViewScaleTransform
            }
        })
    }

    @objc private func stopEvent() {
        playPauseButton.isEnabled = false
        stopButton.isEnabled = false

        switch viewModel.playerState.value {
        case .neutral, .ended: break
        case .playing, .paused:
            viewModel.timer?.invalidate()
            currentTimeSlider.value = Float(0.00)
            viewModel.stop()
            setPlayButton(to: .play)
            playPauseButton.isEnabled = true
            viewModel.playerState.value = .neutral
        }
    }

    private enum PlayPauseState {
        case play
        case pause
    }

    private func setPlayButton(to state: PlayPauseState) {
        let imageName = state == .play ? "play" : "pause"
        playPauseButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    private func dragEvent() {
        playPauseButton.isEnabled = false
        stopButton.isEnabled = false
        switch viewModel.playerState.value {
        case .neutral, .paused, .playing:
            viewModel.timer?.isPaused = true
            viewModel.audioPlayerCurrentTime(currentTimeSlider.value)
            viewModel.timer?.isPaused = false
            playPauseButton.isEnabled = true
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
        currentTimeSlider.isEnabled = false
        currentTimeSlider.isUserInteractionEnabled = false
        playPauseButton.isEnabled = false
        playPauseButton.isUserInteractionEnabled = false
        stopButton.isEnabled = false
        stopButton.isUserInteractionEnabled = false
    }

    private func allow() {
//        spinner.stopAnimating()
//        spinner.isHidden = true
        currentTimeSlider.isEnabled = true
        currentTimeSlider.isUserInteractionEnabled = true
        playPauseButton.isEnabled = true
        playPauseButton.isUserInteractionEnabled = true
        setPlayButton(to: .play)
        stopButton.isEnabled = true
        stopButton.isUserInteractionEnabled = true
    }
    
    
}
