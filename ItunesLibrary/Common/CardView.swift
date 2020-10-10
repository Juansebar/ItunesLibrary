//
//  CardView.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/9/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    private var cardViews: CardViews
    private var isDisplayingFront = true
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let frontView: UIView!
    private let backView: UIView!
    
    init(cardViews: CardViews) {
        self.cardViews = cardViews //(frontView: self.frontView, backView: self.backView)
        frontView = cardViews.frontView
        backView = cardViews.backView
        
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCardAnimation)))
    }
    
    typealias CardViews = (frontView: UIView, backView: UIView)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        containerView.addSubview(backView)
        containerView.addSubview(frontView)
        addSubview(containerView)
        
        backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            frontView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            frontView.topAnchor.constraint(equalTo: containerView.topAnchor),
            frontView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            frontView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            backView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            backView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            backView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc private func flipCardAnimation() {
        if isDisplayingFront {
            cardViews = (frontView: backView, backView: frontView)
        } else {
            cardViews = (frontView: frontView, backView: backView)
        }
        
        isDisplayingFront = !isDisplayingFront
        
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//            self.containerView.transform = .init(scaleX: 0.98, y: 0.98)
//            self.frontView.transform = .init(scaleX: 0.98, y: 0.98)
//            self.backView.transform = .init(scaleX: 0.98, y: 0.98)
//        }, completion: { (_) in
//            UIView.transition(with: self.containerView, duration: 0.5, options: [.transitionFlipFromRight, .curveLinear], animations: {
//                self.containerView.bringSubviewToFront(self.cardViews.frontView)
//            }, completion: { _ in
//                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//                    self.containerView.transform = .identity
//                    self.frontView.transform = .identity
//                    self.backView.transform = .identity
//                })
//            })
//        })
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .autoreverse, animations: {
            self.containerView.transform = .init(scaleX: 0.98, y: 0.98)
            self.frontView.transform = .init(scaleX: 0.98, y: 0.98)
            self.backView.transform = .init(scaleX: 0.98, y: 0.98)
            UIView.transition(with: self.containerView, duration: 0.5, options: [.transitionFlipFromRight, .curveLinear], animations: {
                self.containerView.bringSubviewToFront(self.cardViews.frontView)
            })
        }, completion: { (_) in
                self.containerView.transform = .identity
                self.frontView.transform = .identity
                self.backView.transform = .identity
        })
    }
    
}
