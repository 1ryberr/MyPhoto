//
//  SavedCitiesViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/17/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SavedCitiesViewController: UIViewController {
    
    private var managedObjectContext: NSManagedObjectContext?
    private var favCity = [Favorites]()
    private var weather: OpenWeatherData?
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func save() {
        
        do{
            try managedObjectContext?.save()
            print("saved")
            
         }catch{
            print("caught an error\(error)")
         }
    }
    
    func loadData() {
        managedObjectContext = CoreDataStack().persistentContainer.viewContext
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        request.returnsObjectsAsFaults = false
        do{
            favCity = try (managedObjectContext?.fetch(request))!
        }catch{
            print("caught an error\(error)")
        }
    }
    
    func deleteData(indexPath: IndexPath) {
        
        managedObjectContext = CoreDataStack().persistentContainer.viewContext
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        request.returnsObjectsAsFaults = false
        do{
            favCity = try (managedObjectContext?.fetch(request))!
            managedObjectContext?.delete(favCity[indexPath.row])
        }catch{
            print("caught an error\(error)")
        }
        save()
    }
    
    func addBounceAnimationToView(view: UIView){
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale") as CAKeyframeAnimation
        bounceAnimation.values = [ 2, 1, 2, 1]
        
        let timingFunctions = NSMutableArray(capacity: bounceAnimation.values!.count)
        
        for _ in  0...bounceAnimation.values!.count {
            timingFunctions.add(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        }
        bounceAnimation.timingFunctions = timingFunctions as NSArray as? [CAMediaTimingFunction]
        bounceAnimation.isRemovedOnCompletion = true
        
        view.layer.add(bounceAnimation, forKey: "bounce")
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
   
    func labelFunction(label: UILabel, text: String, color: UIColor) {
        
        let attrs = [NSAttributedString.Key.foregroundColor: color,
                     NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
                     NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString]
        
        let string = NSAttributedString(string: text, attributes: attrs)
        label.attributedText = string
        
    }
}

extension SavedCitiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FavCityTableViewCell
        cell?.uiImageView?.image = UIImage(data: favCity[indexPath.row].photo!)
        labelFunction(label:(cell?.labelView)!, text: favCity[indexPath.row].city!, color: UIColor.red)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            deleteData(indexPath: indexPath )
            favCity.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FavCityTableViewCell else {return}
        cell.animate()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let coordinates = CLLocationCoordinate2D(latitude: favCity[indexPath.row].latitude, longitude: favCity[indexPath.row].longitude)
        guard let cell = tableView.cellForRow(at: indexPath) as? FavCityTableViewCell else {return}
        var spinnerView: UIView!
        spinnerView = SearchAndCollectionViewController.displaySpinner(onView: cell)
      
        let methodParameters = [
            Constants.OpenWeatherKeys.Latitude:  "\(coordinates.latitude)",
            Constants.OpenWeatherKeys.Longitude: "\(coordinates.longitude)",
            Constants.OpenWeatherKeys.TheType: Constants.OpenWeatherValues.TheType,
            Constants.OpenWeatherKeys.Units: Constants.OpenWeatherValues.Units,
            Constants.OpenWeatherKeys.AppID: Constants.OpenWeatherValues.AppID]
     
        FlickrClient.sharedInstance.displayWeatherBySearch(url: "\(WeatherURLFromParameters(methodParameters as [String : AnyObject]))", completionHandlerForPOST: { weather, error in
            
              guard (error == nil) else {
           
              
                let alert = UIAlertController(title: "Error", message: "Weather retrieval failed check your internet connection", preferredStyle: UIAlertController.Style.alert)
                
                let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                    SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
                    self.dismiss(animated: true, completion: {})
                })
                
                alert.addAction(actionOK)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            self.weather = weather!
            
            DispatchQueue.main.async {
                self.addBounceAnimationToView(view: cell)
                cell.tempLabel?.text = "\(Int(round(self.weather?.main.temp ?? 0)))"
                cell.humidityLabel?.text = "\(Int(round(self.weather?.main.humidity ?? 0)))"
                cell.highsLabels?.text = "\(Int(round(self.weather?.main.tempMax ?? 0)))"
                cell.lowsLabel?.text = "\(Int(round(self.weather?.main.tempMin ?? 0)))"
                SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
            }
        });
    }
}
