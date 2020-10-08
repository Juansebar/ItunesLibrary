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
        label.font = Fonts.boldTitle.font
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = .init(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        addSubview(albumImageView)
        addSubview(trackNameLabel)
        addSubview(artistNameLabel)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            albumImageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10),
            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            albumImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            albumImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trackNameLabel.leftAnchor.constraint(equalTo: albumImageView.rightAnchor, constant: 10),
            trackNameLabel.topAnchor.constraint(equalTo: albumImageView.topAnchor),
            trackNameLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            trackNameLabel.leftAnchor.constraint(equalTo: albumImageView.rightAnchor, constant: 10),
            trackNameLabel.topAnchor.constraint(equalTo: albumImageView.topAnchor),
            trackNameLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10)
        ])
    }
    
}
