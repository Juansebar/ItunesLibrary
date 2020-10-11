//
//  MusicFeedCell.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class MusicFeedCell: BaseTableViewCell {
    
    static let identifier = "MusicFeedCellId"
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.mediumBoldTitle.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.text.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.trackNameLabel, self.artistNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
//    override var isHighlighted: Bool {
//        didSet {
//            animate(isHighlighted: isHighlighted)
//        }
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = .init(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(albumImageView)
        addSubview(labelsStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            albumImageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10),
            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            albumImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            albumImageView.heightAnchor.constraint(equalToConstant: 50),
            albumImageView.widthAnchor.constraint(equalToConstant: 50),
            
            labelsStackView.centerYAnchor.constraint(equalTo: albumImageView.centerYAnchor),
            labelsStackView.leftAnchor.constraint(equalTo: albumImageView.rightAnchor, constant: 10),
            labelsStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10)
        ])
    }
    
    func configure(with song: Song) {
        albumImageView.image = nil
        albumImageView.loadImage(urlString: song.artworkUrl60)
        trackNameLabel.text = song.trackName
        artistNameLabel.text = song.artistName
    }
    
    private func animate(isHighlighted: Bool) {
        print(isHighlighted)
        UIView.animate(withDuration: 1, delay: 0, options: isHighlighted ? .curveEaseIn : .curveEaseOut, animations: {
            if isHighlighted {
                self.contentView.backgroundColor = UIColor.blue
            } else {
                self.contentView.backgroundColor = UIColor.yellow
            }
        })
    }
    
}
