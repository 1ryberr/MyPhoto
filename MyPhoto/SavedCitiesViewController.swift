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
    
    var managedObjectContext: NSManagedObjectContext!
    var favCity = [Favorites]()
    var weather = [Double]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func save() {
        
        do{
            try managedObjectContext.save()
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
            favCity = try managedObjectContext.fetch(request)
        }catch{
            print("caught an error\(error)")
        }
    }
    
    func deleteData(indexPath: IndexPath) {
        
        managedObjectContext = CoreDataStack().persistentContainer.viewContext
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        request.returnsObjectsAsFaults = false
        do{
            favCity = try managedObjectContext.fetch(request)
            managedObjectContext.delete(favCity[indexPath.row])
        }catch{
            print("caught an error\(error)")
        }
        save()
    }
    
    func getWeatherData(coordinates: CLLocationCoordinate2D){
        
        let WEATHER_LINK = "https://api.openweathermap.org/data/2.5/weather?&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&type=accurate&units=imperial&appid=645ed60a8e4bfce83c50f48532f8a957"
        
        FlickrClient.sharedInstance.displayWeatherBySearch(url: WEATHER_LINK, completionHandlerForPOST: {weatherData,error in
            
            guard (error == nil) else {
                print("\(error!)")
                return
            }
            
            self.weather = weatherData!
        })
        
    }
}

extension SavedCitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FavCityTableViewCell
        cell.uiImageView.image = UIImage(data: favCity[indexPath.row].photo!)
        cell.labelView.text = favCity[indexPath.row].city
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
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
        
        getWeatherData(coordinates: coordinates)
        guard let cell = tableView.cellForRow(at: indexPath) as? FavCityTableViewCell else {return}
        var spinnerView: UIView!
        spinnerView = SearchAndCollectionViewController.displaySpinner(onView: cell)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            
            cell.tempLabel.text = "\(Int(round((self.weather[0]))))"
            cell.humidityLabel.text = "\(Int(round((self.weather[1]))))"
            cell.highsLabels.text = "\(Int(round((self.weather[2]))))"
            cell.lowsLabel.text = "\(Int(round((self.weather[3]))))"
            SearchAndCollectionViewController.removeSpinner(spinner:spinnerView)
            
        }
    }
}
