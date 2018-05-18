//
//  SavedCitiesViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/17/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import CoreData

class SavedCitiesViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var favCity = [Favorites]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // tableView.isEditing = true
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
         favCity.remove(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .left)
          managedObjectContext.delete(favCity[indexPath.row])
            save()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FavCityTableViewCell else {return}
        cell.animate()
    }
    
    
}
