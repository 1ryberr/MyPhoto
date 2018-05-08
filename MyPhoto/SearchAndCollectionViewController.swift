//
//  SearchAndCollectionViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/1/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchAndCollectionViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImage: UILabel!
    @IBOutlet weak var SearchBTN: UIBarButtonItem!    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var highsLabels: UILabel!
    @IBOutlet weak var lowsLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    var coordinates = CLLocationCoordinate2D()
    var photos = [String]()
    var weather = [Double]()
    let FLICKER_API_KEY = "5502594069909ec1c701e8582fdfa052"
    let WEATHER_MAP_KEY =  "645ed60a8e4bfce83c50f48532f8a957"
    var img : UIImage!
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelFunction(label: cityLabel, text: "City", color: UIColor.black)
        labelFunction(label: tempLabel, text: "0", color: UIColor.black)
        labelFunction(label: humidityLabel, text: "0", color: UIColor.black)
        labelFunction(label: highsLabels, text: "0", color: UIColor.black)
        labelFunction(label: lowsLabel, text: "0", color: UIColor.black)
        
        getCurrentLocation()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        map.addGestureRecognizer(longPress)
        
    }
    
    func getCity(_ lastLocation: CLLocation) {
        geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
            guard (error == nil) else {
                print("\(error!)")
                let alert = UIAlertController(title: "Error", message: "Geolocation has failed! Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let city = placemarks![0].locality
            self.getMapByAddress(map:self.map, address:city!)
            
        })
    }
    
    func getCurrentLocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let lastLocation = self.locationManager.location {
            getCity(lastLocation)
        }
    }
    
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer){
        
        if press.state == .began{
            let longTouchPoint = press.location(in: map)
            let coordinates = map.convert(longTouchPoint, toCoordinateFrom: map)
            pinCoordinates(coordinates)
        }
    }
    
    func pinCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        let getLat: CLLocationDegrees = coordinates.latitude
        let getLon: CLLocationDegrees = coordinates.longitude
        let touchPoint: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
        getCity(touchPoint)
        map.addAnnotation(annotation)
    }
    
    func labelFunction(label: UILabel, text: String, color: UIColor) {
        
        let attrs = [NSAttributedStringKey.foregroundColor: color,
                     NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
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
                self.coordinates = (validPlacemark.location?.coordinate)!
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: (self.coordinates), span: span)
                self.map.setCenter(self.coordinates, animated: true)
                self.map.setRegion(region, animated: true)
                
                self.getFlickData(coordinates: self.coordinates)
                self.getWeatherData(coordinates: self.coordinates)
                self.cityLabel.text = placemarks![0].name
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
    
    func getWeatherData(coordinates: CLLocationCoordinate2D){
        
        let WEATHER_LINK = "https://api.openweathermap.org/data/2.5/weather?&lat=\(self.coordinates.latitude)&lon=\(self.coordinates.longitude)&type=accurate&units=imperial&appid=645ed60a8e4bfce83c50f48532f8a957"
        FlickrClient.sharedInstance.displayWeatherBySearch(url: WEATHER_LINK, completionHandlerForPOST: {weatherData,error in
            
            guard (error == nil) else {
                print("\(error!)")
                return
            }
            
            self.weather = weatherData!
            
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(round((weatherData?[0])!)))"
                self.humidityLabel.text = "\(Int(round((weatherData?[1])!)))"
                self.highsLabels.text = "\(Int(round((weatherData?[2])!)))"
                self.lowsLabel.text = "\(Int(round((weatherData?[3])!)))"
                
            }
            
        })
        
    }
    
    
    @IBAction func SearchActBTN(_ sender: Any) {
        map.isHidden ? flip():flipMap()
    }
    
    @IBAction func mapBTN(_ sender: Any) {
        searchTextField.resignFirstResponder()
        getMapByAddress(map: map, address: searchTextField.text!)
        searchTextField.text = ""
        
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

extension SearchAndCollectionViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
extension SearchAndCollectionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier: String = "Pin"
        
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
            return annotationView
        }
        return annotationView
    }
}
