//
//  WebProvider.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/7/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import Foundation

enum FetchError: Error {
    case invalidUrl
    case invalidResponse
    case noData
    case failedRequest(String)
    case invalidData
    case serverError
}

protocol WebProviderContract {
    static func fetchItunesMusic(completion: @escaping (Result<[Song], FetchError>) -> Void)
}

class WebProvider: WebProviderContract {
    
    static private let host = "itunes.apple.com"
    static private let path = "search"
    
    enum Endpoints {
        case fetchMusic(String)
        
        var url: URL? {
            var urlBuilder = URLComponents()
            
            switch self {
            case .fetchMusic(let searchTerm):
//                urlBuilder.scheme = "https"
//                urlBuilder.path = "/search?"
//                urlBuilder.
                let formattedSearchTerm = searchTerm.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")
                return URL(string: "https://itunes.apple.com/search?entity=song&term=\(formattedSearchTerm)")
            }
        }
    }
    
    static func fetchItunesMusic(completion: @escaping (Result<[Song], FetchError>) -> Void) {
        guard let url = Endpoints.fetchMusic("Michael Jackson").url else {
            completion(.failure(.invalidUrl))
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
            
            let status = response.statusCode
            guard (200...299).contains(status) else {
                completion(.failure(.serverError))
                return
            }
            
            do {
                let songsInfo = try JSONDecoder().decode(SongsContainer.self, from: data)
                completion(.success(songsInfo.songs))
            } catch {
                completion(.failure(.invalidData))
            }
        }.resume()
    }
    
}

