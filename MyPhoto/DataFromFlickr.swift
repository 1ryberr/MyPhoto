//
//  DataFromFlickr.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/1/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import Foundation


struct FlickrPagedImageResult:  Codable {
    let photos: Photos?
    let stat: String
    
}

struct Photos: Codable {
    let photo: [Photo]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
}

struct Photo: Codable {
    let url_m: String
}

struct OpenWeatherData: Codable {
    var main: Main
}

struct Main: Codable {
    let temp: Double
    let humidity: Double
    let tempMin: Double
    let tempMax:Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}
