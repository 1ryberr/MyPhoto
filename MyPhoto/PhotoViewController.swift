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
    
    var photo: URL?
    var img : UIImage?
    var city: String?
    var longitude: Double?
    var latitude: Double?
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var imageView: UIImageView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
          displayPhoto(pic: photo!)
    }
    
    func displayPhoto(pic: URL) {
        let imageURL =  photo
        
        if let imageData: Data = try? Data(contentsOf: imageURL!){
            self.img = UIImage(data: imageData)!
              imageView.image = img
            
        }else {
            let alert = UIAlertController(title: "Error", message: "internet connection failed! Try again later.", preferredStyle: UIAlertController.Style.alert)
            
            let actionOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                self.dismiss(animated: true, completion: {})
            })
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
      
    }
    
    func savaData() {
        managedObjectContext = CoreDataStack().persistentContainer.viewContext
        let myFav: Favorites = Favorites(context: managedObjectContext)
        myFav.latitude = latitude!
        myFav.longitude = longitude!
        myFav.city = city
        let imageURL =  photo
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
