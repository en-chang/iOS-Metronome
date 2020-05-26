//
//  SearchData.swift
//  Metronome
//
//  Created by Ian Chang on 11/17/19.
//  Copyright © 2019 Ian Chang. All rights reserved.
//

import Foundation

struct SearchResponse:Decodable {
    var search:[SearchData]
}

struct SearchData:Decodable {
    var song_title:String
    var tempo:String
    var time_sig:String
    var artist:ArtistData
    var album:AlbumData
}

struct ArtistData:Decodable {
    var name:String
}

struct AlbumData:Decodable {
    var img:String
}
