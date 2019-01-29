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
    @IBOutlet weak var flipViewBTN: UIBarButtonItem!
    
    var coordinates = CLLocationCoordinate2D()
    var photos = [URL]()
    var weather = [Double]()
    var img: UIImage!
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var city: String!
    var numberOfPages: Int = 0
    let refreshControls = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        getCurrentLocation()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        map.addGestureRecognizer(longPress)
        updateCurrentLocation()
        
    }
    
    func getCity(_ lastLocation: CLLocation) {
        geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
            guard (error == nil) else {
        
                let alert = UIAlertController(title: "Error", message: "Geolocation has failed! Try again later.", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            
            if placemarks![0].locality != nil {
            
             let cityState = "\(placemarks![0].locality!)" + "," + "\(placemarks![0].administrativeArea!)"
             self.getMapByAddress(map:self.map, address:cityState)
                
            }else {
                let alert = UIAlertController(title: "Error", message: "Geolocation not vaild try another.", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                    self.removePinCoordinates()
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)            }
      
     
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
            removePinCoordinates()
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
        
        let attrs = [NSAttributedString.Key.foregroundColor: color,
                     NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
    
    func flipMap() {
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        UIView.transition(with: map, duration: 1.0, options: transitionOptions, animations: {
        })
        self.map.isHidden = true
        UIView.transition(with: searchView, duration: 1.0, options: transitionOptions, animations: {
        })
        self.searchView.isHidden = false
        
    }
    
    func flip() {
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        UIView.transition(with: searchView, duration: 1.0, options: transitionOptions, animations: {
        })
        self.searchView.isHidden = true
        UIView.transition(with: map, duration: 1.0, options: transitionOptions, animations: {
        })
        self.map.isHidden = false
        
    }
    
    func removePinCoordinates() {
        let annotations = map.annotations
        map.removeAnnotations(annotations)
    }
    
    func getMapByAddress(map:MKMapView, address:String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address){ placemarks, error in
            guard (error == nil) else {
                print("\(error!)")
                let alert = UIAlertController(title: "Error", message: "Geolocation has failed! Try again later.", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let validPlacemark = placemarks?[0]{
                
                self.coordinates = (validPlacemark.location?.coordinate)!
                let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: (self.coordinates), span: span)
                self.map.setRegion(region, animated: true)
                
                self.getFlickData(coordinates: self.coordinates)
                self.getWeatherData(coordinates: self.coordinates)
                self.city = placemarks![0].name
                self.labelFunction(label: self.cityLabel, text: self.city, color: UIColor.black)
                
            }
            
        }
    }
    
    func getFlickData(coordinates: CLLocationCoordinate2D) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Latitude:  "\(coordinates.latitude)",
            Constants.FlickrParameterKeys.Longitude: "\(coordinates.longitude)",
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.Page:  "\(Int(arc4random_uniform(UInt32(numberOfPages))) + 1)",
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        var spinnerView: UIView!
        spinnerView = SearchAndCollectionViewController.displaySpinner(onView: searchView)
        
        FlickrClient.sharedInstance.displayImageFromFlickrBySearch(url: "\(flickrURLFromParameters(methodParameters as [String : AnyObject]))",completionHandlerForPOST: {myImages, pages,error in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "Image download has failed! Check internet connection.", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                 SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.numberOfPages = pages
            self.photos = myImages!
            
            SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        })
        
    }
    
    func getWeatherData(coordinates: CLLocationCoordinate2D){
        
        let methodParameters = [
            Constants.OpenWeatherKeys.Latitude:  "\(coordinates.latitude)",
            Constants.OpenWeatherKeys.Longitude: "\(coordinates.longitude)",
            Constants.OpenWeatherKeys.TheType: Constants.OpenWeatherValues.TheType,
            Constants.OpenWeatherKeys.Units: Constants.OpenWeatherValues.Units,
            Constants.OpenWeatherKeys.AppID: Constants.OpenWeatherValues.AppID]
        
        var spinnerView: UIView!
        spinnerView = SearchAndCollectionViewController.displaySpinner(onView: searchView)
        
        FlickrClient.sharedInstance.displayWeatherBySearch(url: "\(WeatherURLFromParameters(methodParameters as [String : AnyObject]))", completionHandlerForPOST: {weatherData,error in
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "Weather data download has failed! Check internet connection.", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                   SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
                    self.dismiss(animated: true, completion: {})
                })
                alert.addAction(actionOK)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.weather = weatherData!
            
            DispatchQueue.main.async {
                
                self.tempLabel.text = "\(Int(round((weatherData?[0])!)))"
                self.humidityLabel.text = "\(Int(round((weatherData?[1])!)))"
                self.highsLabels.text = "\(Int(round((weatherData?[2])!)))"
                self.lowsLabel.text = "\(Int(round((weatherData?[3])!)))"
                SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
            }
            
        })
        
    }
    
    
    @IBAction func SearchActBTN(_ sender: Any) {
        
        if map.isHidden{
            SearchBTN.title = "Search"
            flip()
        }else if searchView.isHidden {
            SearchBTN.title = "Map"
            flipMap()
        }
    }
    @objc func refresh() {
        getCurrentLocation()
        collectionView?.refreshControl?.endRefreshing()
    }
    
    func updateCurrentLocation(){
        
        let attrs = [NSAttributedString.Key.foregroundColor:UIColor.white,
                     NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString]
        
        let string = NSAttributedString(string: "Updating Current Location", attributes: attrs)
        
        refreshControls.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        refreshControls.attributedTitle = string
        refreshControls.tintColor = .white
        collectionView?.refreshControl = refreshControls
    }
    
    
    @IBAction func mapBTN(_ sender: Any) {
        
        searchTextField.resignFirstResponder()
        getMapByAddress(map: map, address: searchTextField.text!)
        searchTextField.text = ""
        
    }
    
    @IBAction func savedCities(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "savedCities") as! SavedCitiesViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension SearchAndCollectionViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count == 0 {
            noImage.isHidden = false
        }else{
            noImage.isHidden = true
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        var spinnerView: UIView!
        spinnerView = SearchAndCollectionViewController.displaySpinner(onView: cell)
        
        let imageUrl =  self.photos[indexPath.item]
        
        FlickrClient.sharedInstance.downloadImage(url: imageUrl){(image, error)in
            let loadedImage: UIImage
            if error == nil {
                loadedImage = image!
                DispatchQueue.main.async {
                    cell.photoImage.image = loadedImage
                    SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
                    
                }
            } else{
             SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "detail") as! PhotoViewController
        
        vc.longitude = coordinates.longitude
        vc.latitude = coordinates.latitude
        vc.city = city
        vc.photo = photos[indexPath.item]
        
        present(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:(UIScreen.main.bounds.width - 20)/3, height:(UIScreen.main.bounds.width - 20)/3)
    }
    
    
    func WeatherURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.OpenWeather.APIScheme
        components.host = Constants.OpenWeather.APIHost
        components.path = Constants.OpenWeather.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
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

extension  SearchAndCollectionViewController{
    
    class func displaySpinner(onView : UIView) -> UIView {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.clear
        let ai  = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
            
        }
        
    }
    
    
}
