//
//  PhotoViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/15/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
 var photo: String!
var img : UIImage!
let imageCache = NSCache<NSString, UIImage>()

    @IBOutlet weak var imageView: UIImageView!
     @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        displayPhoto(pic: photo)
        
    }

 func displayPhoto(pic: String) {
        let imageURL = URL(string: photo)
    
    if let imageData = try? Data(contentsOf: imageURL!){
        self.img = UIImage(data: imageData)!
    }
        imageView.image = img
    }
    
    
    
    
   
    @IBAction func saveBTN(_ sender: Any) {
        
    }
    
    
    
}
