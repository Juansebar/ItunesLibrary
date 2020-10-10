//
//  ImageCache.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

public class ImageCache {
    public static let publicCache = ImageCache()
    private let cachedImages = NSCache<AnyObject, UIImage>()
    
    private let webProvider = WebProvider()
    
    init() {
        cachedImages.totalCostLimit = 20
    }
    
    public final func image(url: URL) -> UIImage? {
        return cachedImages.object(forKey: url as AnyObject)
    }
    
    final func load(url: URL, completion: @escaping (Result<UIImage?, FetchError>) -> Void) {
        if let cachedImage = image(url: url) {
            completion(.success(cachedImage))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.failedRequest(error!.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            let statusCode = response.statusCode
            guard (200...299).contains(statusCode) else {
                completion(.failure(.serverError))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }
            
            self.cachedImages.setObject(image, forKey: url as AnyObject, cost: 1)
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }
}
