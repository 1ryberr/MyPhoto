//
//  ViewController.swift
//  MyPhoto
//
//  Created by Ryan Berry on 4/27/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var FLICKER_API_KEY = "5502594069909ec1c701e8582fdfa052"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let FLICKER_LINK = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FLICKER_API_KEY)&lat=\(37.4316)&lon=\(78.6569)&extras=url_m&page=\(1)&format=json&nojsoncallback=1"
        FlickrClient.sharedInstance.displayImageFromFlickrBySearch(url:FLICKER_LINK,completionHandlerForPOST: {myImages,error in
            guard (error == nil) else {
                print("\(error!)")
                return
            }
            
            print(myImages)
            
        })
        
    }
}
