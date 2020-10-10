//
//  UIImageView+Extensions.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

extension UIImageView {
    final func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if let cachedImage = ImageCache.publicCache.image(url: url) {
            self.image = cachedImage
        }
        
        ImageCache.publicCache.load(url: url) { [weak self] (result) in
            switch result {
            case .failure(_):
                print("An error occured while fetching tweet author profile photo.")
                self?.image = nil
            case .success(let image):
                self?.image = image
            }
        }
    }
}
