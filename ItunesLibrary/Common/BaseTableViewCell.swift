//
//  BaseTableViewCell.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isSeparatorLineVisible: Bool = true {
        didSet {
            separatorLine.isHidden = !isSeparatorLineVisible
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        selectionStyle = .none
        
        addSubview(separatorLine)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            separatorLine.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            separatorLine.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
}
