//
//  Song.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/7/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import Foundation

struct SongsContainer: Decodable {
    let songs: [Song]
    
    enum CodingKeys: String, CodingKey {
        case songs = "results"
    }
}

struct Song: Decodable {
    let artistId: Int
    let collectionId: Int
    let trackId: Int
    let artistName: String
    let collectionName: String
    let trackName: String
    let previewUrl: String
    let artworkUrl30: String
    let artworkUrl60: String
    let artworkUrl100: String
    let collectionPrice: Double
    let trackPrice: Double
    let currency: String
    let releaseDate: String
    let trackTimeMillis: Int
    let genre: String
    let trackNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case artistId
        case collectionId
        case trackId
        case artistName
        case collectionName
        case trackName
        case previewUrl
        case artworkUrl30
        case artworkUrl60
        case artworkUrl100
        case collectionPrice
        case trackPrice
        case currency
        case releaseDate
        case trackTimeMillis
        case genre = "primaryGenreName"
        case trackNumber
    }
}

struct Artist: Decodable {
    let id: Int
    let name: String
    
    
}
