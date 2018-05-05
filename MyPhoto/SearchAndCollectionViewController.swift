//
//  SearchAndCollectionViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/1/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import MapKit


class SearchAndCollectionViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImage: UILabel!
     @IBOutlet weak var SearchBTN: UIBarButtonItem!
    
    
    
    
    var coordinates = CLLocationCoordinate2D()
    var photos = [String]()
    let FLICKER_API_KEY = "5502594069909ec1c701e8582fdfa052"
    let WEATHER_MAP_KEY =  "645ed60a8e4bfce83c50f48532f8a957"
    var img : UIImage!
    var city: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string:  "https://api.openweathermap.org/data/2.5/weather?&lat=38.385111000000002&lon=-78.975020999999998&type=accurate&units=imperial&appid=645ed60a8e4bfce83c50f48532f8a957")
        
        var request = URLRequest(url: url!)
     //   request.httpMethod = "GET"
      //  request.addValue("application/json", forHTTPHeaderField: "content-type")
      
        
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        
     //   let defaultSession
          // = URLSession(configuration: config)
        
        
     URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                //completionHandlerForPOST(nil, NSError(domain: "getStudentInfo", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
              print("There was an error with your request: \(error?.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
               print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
        
 let dataAsString = String(data: data, encoding: .utf8)
        
        print(dataAsString)
        }
     .resume()
        
 
        
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func flipMap() {
        
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: map, duration: 1.0, options: transitionOptions, animations: {
            
        })
        self.map.isHidden = true
        UIView.transition(with: searchView, duration: 1.0, options: transitionOptions, animations: {
            
        })
        self.searchView.isHidden = false
        
    }
    
    
    
    func flip() {
        
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: searchView, duration: 1.0, options: transitionOptions, animations: {
            
        })
        self.searchView.isHidden = true
        UIView.transition(with: map, duration: 1.0, options: transitionOptions, animations: {
            
        })
        self.map.isHidden = false
        
    }
    
    func getMapByAddress(map:MKMapView, address:String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address){ placemarks, error in
            guard (error == nil) else {
                print("\(error!)")
                let alert = UIAlertController(title: "Error", message: "Geolocation has failed! Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                    //   LoginViewController.removeSpinner(spinner: self.sv)
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let validPlacemark = placemarks?[0]{
                self.flip()
                self.coordinates = (validPlacemark.location?.coordinate)!
                print()
                let span = MKCoordinateSpanMake(0.04, 0.04)
                let region = MKCoordinateRegion(center: (self.coordinates), span: span)
                self.map.setRegion(region, animated: true)
                self.getFlickData(coordinates: self.coordinates)
                
                print(self.coordinates)
            }
            
        }
    }
    
    func getFlickData(coordinates: CLLocationCoordinate2D) {
        
        let FLICKER_LINK = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(self.FLICKER_API_KEY)&lat=\(self.coordinates.latitude)&lon=\(self.coordinates.longitude)&extras=url_m&page=\(1)&format=json&nojsoncallback=1"
        FlickrClient.sharedInstance.displayImageFromFlickrBySearch(url:FLICKER_LINK,completionHandlerForPOST: {myImages,error in
            guard (error == nil) else {
                print("\(error!)")
                return
            }
            self.photos = myImages!
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        })
        
    }
    
    
   
    @IBAction func SearchActBTN(_ sender: Any) {
        
     flipMap()
        
        
        
    }
    
    
    
    @IBAction func mapBTN(_ sender: Any) {
        
        getMapByAddress(map: map, address: searchTextField.text!)
        
    }
    
}


extension SearchAndCollectionViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        DispatchQueue.global(qos:.userInitiated).async {
            let imageURL = URL(string: self.photos[indexPath.item])
            
            if let imageData = try? Data(contentsOf: imageURL!){
                
                self.img = UIImage(data: imageData)!
                
            }
            DispatchQueue.main.async {
                
                cell.photoImage.image = self.img
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:(UIScreen.main.bounds.width - 20)/3, height:(UIScreen.main.bounds.width - 20)/3)
    }
    
}
