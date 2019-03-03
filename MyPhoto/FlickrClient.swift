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
     @discardableResult
    func displayImageFromFlickrBySearch(url: String, completionHandlerForPOST: @escaping (_ myImages: [URL]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
       
        let url = URL(string: url)!
        let request = URLRequest(url: url)
        
        let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil,NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error?.localizedDescription))")
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
            
            let parsedResults : FlickrPagedImageResult
       
            do {
                parsedResults = try JSONDecoder().decode(FlickrPagedImageResult.self, from: data)
                
            }catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
              var myImages = [URL]()
            for photo in (parsedResults.photos?.photo)! {
                myImages.append(photo.url!)
            }
            
            if !(parsedResults.photos?.photo.isEmpty)! {
                completionHandlerForPOST(myImages,nil)
            }else{
                let myImages: [URL] = []
                completionHandlerForPOST(myImages, nil)
            }
        }
        task.resume()
        return task
    }
    @discardableResult
    func displayWeatherBySearch(url: String, completionHandlerForPOST: @escaping (_ weather: [Double]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var weatherData = [Double]()
        let url = URL(string: url)
        var request = URLRequest(url: url!)
        let task =  URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error?.localizedDescription ))")
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
    
    func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
         let imageCache = NSCache<NSString, UIImage>()
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(image, nil)
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    
                } else if let data = data, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(image, nil)
                } else {
                    completion(nil, error)
                }
            }
            
        task.resume()
        }
       
    }
    
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}


