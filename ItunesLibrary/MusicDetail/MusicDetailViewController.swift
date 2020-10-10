//
//  MusicDetailViewController.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/9/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class MusicDetailViewController: UIViewController {

    private let viewModel: MusicDetailViewModelContract
    
    
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
        
        albumNameLabel.attributedText = viewModel.collectionName
        releaseDateLabel.attributedText = viewModel.releaseDate
        genreLabel.attributedText = viewModel.genre
        priceLabel.attributedText = viewModel.trackPrice
    }
    
    func setupViews() {
        view.addSubview(cardView)
        view.addSubview(trackLabelsStackView)
        
        infoView.addSubview(additionInfoStackView)
        
        songNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
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
    }

}
