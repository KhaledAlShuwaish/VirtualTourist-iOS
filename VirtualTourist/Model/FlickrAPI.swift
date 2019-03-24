//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Khaled Shuwaish on 25/02/2019.
//  Copyright © 2019 Khaled Shuwaish. All rights reserved.
//

import UIKit

class FlickrAPI {

    static let shared = FlickrAPI()
    private init() {}
    
    var arrayOfPhotos = [String]()
    
    func getPhotoFromAPI(pin: Pin, completion: @escaping ([String]?) -> Void){
        let parameter = [APIContents.Parameter.Method : APIContents.ParameterValues.SearchMethod,
                         APIContents.Parameter.APIKey : APIContents.ParameterValues.APIKey,
                         APIContents.Parameter.latitude : pin.latitude,
                         APIContents.Parameter.longtiude : pin.longitude,
                         APIContents.Parameter.Format : APIContents.ParameterValues.ResponseFormat,
                         APIContents.Parameter.PhotosPerPage : APIContents.ParameterValues.PhotosPerPage,
                         APIContents.Parameter.radius : APIContents.ParameterValues.radius,
                         APIContents.Parameter.radiusUnit : APIContents.ParameterValues.radiusUnit,
                         APIContents.Parameter.Extras : APIContents.ParameterValues.MediumURL,
                         APIContents.Parameter.NoJSONCallback : APIContents.ParameterValues.DisableJSONCallback,
                         APIContents.Parameter.page : APIContents.ParameterValues.randomInt
            ] as [String : Any]
        
        let fullURL = RemainingFromURL(parameter: parameter)
        
        let request = URLRequest(url: fullURL)
//        let url = URL(string: "https://api.flickr.com/services/rest/")
        
        URLSession.shared.dataTask(with: request) { (data, Response, error) in
            if let newData = data {
                let khaled : [String : Any]
                do{
                    khaled = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : Any]
                }catch{
                    print("Error")
                    return
                }
                
                if let photosDictionary = khaled[APIContents.Response.photos] as? [String : Any], let photoArray = photosDictionary[APIContents.Response.photo] as? [[String : Any]] {
                    for photo in photoArray {
                        if let imageURLString = photo[APIContents.Response.mediumURL] as? String {
                            self.arrayOfPhotos.append(imageURLString)
                                                    }
                    }
                    completion(self.arrayOfPhotos)
                }
                
            }
        }
        
        .resume()
    }
    
    func RemainingFromURL (parameter : [String : Any]) -> URL{
        
        var co  = URLComponents()
        co.scheme = "https"
        co.host = "api.flickr.com"
        co.path = "/services/rest"
        co.queryItems = [URLQueryItem]()
        for (key,value) in parameter {
            let query = URLQueryItem(name: key, value: "\(value)")
            co.queryItems?.append(query)
        }
        let fullURL = co.url
        
        return fullURL!
    }

}
