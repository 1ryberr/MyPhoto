//
//  PhotoViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/15/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import CoreData

class PhotoViewController: UIViewController {
    
    var photo: String!
    var img : UIImage!
    var city: String!
    var longitude: Double!
    var latitude: Double!
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayPhoto(pic: photo)
        managedObjectContext = CoreDataStack().persistentContainer.viewContext
    }
    
    func displayPhoto(pic: String) {
        let imageURL = URL(string: photo)
        
        if let imageData: Data = try? Data(contentsOf: imageURL!){
            self.img = UIImage(data: imageData)!
        }
        imageView.image = img
    }
    
    func savaData() {
        let myFav: Favorites = Favorites(context: managedObjectContext)
        myFav.latitude = latitude
        myFav.longitude = longitude
        myFav.city = city
        let imageURL = URL(string: photo)
        if let imageData = try? Data(contentsOf: imageURL!){
            myFav.photo = imageData as NSData as Data
        }
        save()
        
        dismiss(animated: true, completion: {})
    }
    
    func save() {
        
        do{
            try managedObjectContext.save()
            print("saved")
            
        }catch{
            print("caught an error\(error)")
        }
    }
    
    
    @IBAction func saveBTN(_ sender: Any) {
        savaData()
        
    }
    
    @IBAction func cancelBTN(_ sender: Any) {
        dismiss(animated: true, completion: {})
        
    }
    
    
}
