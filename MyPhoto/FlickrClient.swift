//
//  FlickrClient.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/1/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit



class FlickrClient: NSObject{
    
    static let sharedInstance = FlickrClient()
    private override init() {}
    
    func displayImageFromFlickrBySearch(url: String, completionHandlerForPOST: @escaping (_ myImages: [String]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var myImages = [String]()
        
        let url = URL(string: url)!
        let request = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        
        let defaultSession = URLSession(configuration: config)
        
        
        let task = defaultSession.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error?.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let code : FlickrPagedImageResult
            do {
                code = try JSONDecoder().decode(FlickrPagedImageResult.self, from: data)
                
                for photo in (code.photos?.photo)!{
                    myImages.append(photo.url_m)
                }
                
                
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            if !(code.photos?.photo.isEmpty)! {
                completionHandlerForPOST(myImages, nil)
            }else{
                let myImages: [String] = []
                completionHandlerForPOST(myImages, nil)
            }
        }
        task.resume()
        return task
    }
    
    func displayWeatherBySearch(url: String, completionHandlerForPOST: @escaping (_ weather: [Double]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var weatherData = [Double]()
        
        let url = URL(string: url)
        
        var request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        
        let defaultSession = URLSession(configuration: config)
        
        
        let task = defaultSession.dataTask(with: request) { (data, response, error) in
            
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error?.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString!)
            
            let decoder = JSONDecoder()
            let weather: OpenWeatherData
            do{
                weather = try decoder.decode(OpenWeatherData.self, from: data)
                weatherData.append(weather.main.temp)
                weatherData.append(weather.main.humidity)
                weatherData.append(weather.main.tempMax)
                weatherData.append(weather.main.tempMin)
             
            }catch{
                 sendError("Could not parse the data as JSON: '\(data)'")
            }
            
            completionHandlerForPOST(weatherData, nil)
            
        }
        task.resume()
        
        
        return task
    }
    
    
    
}
