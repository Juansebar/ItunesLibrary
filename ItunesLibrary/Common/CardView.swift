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
    
    private var interactionTimer: Timer?
    
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
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurredEffectView
    }()
    
    init(cardViews: CardViews) {
        self.cardViews = cardViews //(frontView: self.frontView, backView: self.backView)
        frontView = cardViews.frontView
        backView = cardViews.backView
        
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
        setupTimer()
        
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
        backView.insertSubview(blurView, at: 0)
        
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
            backView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            blurView.heightAnchor.constraint(equalTo: frontView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: frontView.widthAnchor),
            blurView.centerYAnchor.constraint(equalTo: frontView.centerYAnchor),
            blurView.centerXAnchor.constraint(equalTo: frontView.centerXAnchor),
        ])
        
        blurView.frame = backView.bounds
    }
    
    private func setupTimer() {
        interactionTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (_) in
            self.showInteractionAnimation()
        })
    }
    
    private func showInteractionAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.autoreverse, .allowUserInteraction], animations: {
            self.containerView.transform = .init(scaleX: 0.98, y: 0.98)
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: <#T##CGFloat#>, options: <#T##UIView.AnimationOptions#>, animations: <#T##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        }, completion: { (_) in
            self.containerView.transform = .identity
        })
    }
    
    @objc private func flipCardAnimation() {
        interactionTimer?.invalidate()
        
        if isDisplayingFront {
            cardViews = (frontView: backView, backView: frontView)
        } else {
            cardViews = (frontView: frontView, backView: backView)
        }
        
        isDisplayingFront = !isDisplayingFront
        
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.containerView.transform = .init(scaleX: 0.98, y: 0.98)
            self.frontView.transform = .init(scaleX: 0.98, y: 0.98)
            self.backView.transform = .init(scaleX: 0.98, y: 0.98)
        }, completion: { (_) in
            UIView.transition(with: self.containerView, duration: 0.5, options: [.transitionFlipFromRight, .curveLinear], animations: {
                self.containerView.bringSubviewToFront(self.cardViews.frontView)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.containerView.transform = .identity
                    self.frontView.transform = .identity
                    self.backView.transform = .identity
                    
                    self.isUserInteractionEnabled = true
                })
            })
        })
    }
    
}
