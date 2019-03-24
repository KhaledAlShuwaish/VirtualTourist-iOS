//
//  APIContents.swift
//  VirtualTourist
//
//  Created by Khaled Shuwaish on 26/02/2019.
//  Copyright © 2019 Khaled Shuwaish. All rights reserved.
//

import Foundation

struct APIContents{
    
    static let api_key = "5708b4524e4259bf113c4c3a43de02d6"

    static let FullURL = "https://api.flickr.com/services/rest/"
    struct  Parameter {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Extras = "extras"
        static let SafeSearch = "safe_search"
        static let radius = "radius"
        static let radiusUnit = "radius_units"
        static let PhotosPerPage = "per_page"
        static let BoundingBox = "bbox"
        static let latitude = "lat"
        static let longtiude = "lon"
        static let page = "page"

    }

    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = api_key
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "21"
        static let radius = "5"
        static let radiusUnit = "km"
        static let randomInt = Int(arc4random_uniform(UInt32(30)))

    }
    
    struct Response {
        static let photos = "photos"
        static let photo = "photo"
        static let mediumURL = "url_m"
    }
}
