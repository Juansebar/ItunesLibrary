//
//  PlayerView.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/11/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate: class {
    
    func didTapPlayPauseButton()
    func sliderDidChange(value: Float)
    
}

enum PlayPauseState {
    case play
    case pause
}

class PlayerView: UIView {
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.isEnabled = false
        button.addTarget(self, action: #selector(playPauseEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private(set) lazy var currentTimeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = Colors.red.color
        slider.thumbTintColor = Colors.white.color
        slider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidTouchUp), for: .touchUpInside)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.lightGray.color
        label.font = Fonts.text.font
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.lightGray.color
        label.font = Fonts.text.font
        label.text = "--:--"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.currentTimeLabel, self.durationLabel])
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    weak var delegate: PlayerViewDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        addSubview(playPauseButton)
        addSubview(currentTimeSlider)
        addSubview(timeStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            playPauseButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            currentTimeSlider.leftAnchor.constraint(equalTo: leftAnchor),
            currentTimeSlider.rightAnchor.constraint(equalTo: rightAnchor),
            currentTimeSlider.bottomAnchor.constraint(equalTo: timeStackView.topAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            timeStackView.leftAnchor.constraint(equalTo: leftAnchor),
            timeStackView.rightAnchor.constraint(equalTo: rightAnchor),
            timeStackView.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor)
        ])
    }
    
    func setPlayPauseButton(to state: PlayPauseState) {
        let imageName = state == .play ? "play" : "pause"
        playPauseButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func allow() {
        currentTimeSlider.isEnabled = true
        currentTimeSlider.isUserInteractionEnabled = true
        playPauseButton.isEnabled = true
        playPauseButton.isUserInteractionEnabled = true
        setPlayPauseButton(to: .play)
    }
    
    func disallow() {
        currentTimeSlider.isEnabled = false
        currentTimeSlider.isUserInteractionEnabled = false
        playPauseButton.isEnabled = false
        playPauseButton.isUserInteractionEnabled = false
    }
    
    @objc private func playPauseEvent() {
        delegate?.didTapPlayPauseButton()
    }
    
    private var isCurrentTimeSliderBeingDragged = false
    
    @objc private func sliderDidChange() {
//        delegate?.sliderDidChange(value: currentTimeSlider.value)
        isCurrentTimeSliderBeingDragged = true
    }
    
    @objc private func sliderDidTouchUp() {
        isCurrentTimeSliderBeingDragged = false
        delegate?.sliderDidChange(value: currentTimeSlider.value)
    }
    
    func updateCurrentTimeSlider(to value: Float) {
        guard !isCurrentTimeSliderBeingDragged else { return }
        
        currentTimeSlider.value = value
    }
    
}
