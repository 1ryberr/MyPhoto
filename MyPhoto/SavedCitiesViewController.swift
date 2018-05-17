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




    override func viewDidLoad() {
        super.viewDidLoad()
   
    managedObjectContext = CoreDataStack().persistentContainer.viewContext
        
        
        
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        request.returnsObjectsAsFaults = false
        do{
           favCity = try managedObjectContext.fetch(request)
            print(favCity)
        }catch{
            print("caught an error\(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
 

}
extension SavedCitiesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        return cell!
    }
    
    
}
