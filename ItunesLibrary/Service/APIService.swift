//
//  APIService.swift
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

protocol APIServiceContract {
    static func fetchItunesMusic(searchTerm: String, completion: @escaping (Result<[Song], FetchError>) -> Void)
}

class APIService: APIServiceContract {
    
    static private let host = "itunes.apple.com"
    static private let path = "search"
    
    enum Endpoints {
        case fetchMusic(String)
        
        var url: URL? {
            switch self {
            case .fetchMusic(let searchTerm):
                var components = URLComponents(string: "https://\(host)/\(path)")
                let term = cleanSearchQuery(searchTerm: searchTerm)
                let queryItems = [URLQueryItem(name: "entity", value: "song"), URLQueryItem(name: "term", value: term)]
                components?.queryItems = queryItems
                
                return components?.url
            }
        }
        
        private func cleanSearchQuery(searchTerm: String) -> String? {
            return searchTerm.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    }
    
    static func fetchItunesMusic(searchTerm: String, completion: @escaping (Result<[Song], FetchError>) -> Void) {
        guard let url = Endpoints.fetchMusic(searchTerm).url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
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
            }
        }.resume()
    }
    
}
