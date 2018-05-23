//
//  Constants.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/23/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import Foundation
struct Constants {
  
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "5502594069909ec1c701e8582fdfa052"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let Latitude = " "
        static let Longitude = " "
        static let page = ""
        
    }
    struct OpenWeather {
        static let APIScheme = "https"
        static let APIHost = "api.openweathermap.org"
        static let APIPath = "/data/2.5/weather"
    }
    struct OpenWeatherKeys {
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let TheType = "type"
        static let Units = "units"
        static let AppID = "appid"
        
    }
    struct OpenWeatherValues {
       
        static let TheType = "accurate"
        static let Units = "imperial"
        static let AppID = "645ed60a8e4bfce83c50f48532f8a957"
        
    }
    
}
