//
//  PhotoCollectionViewCell.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/21/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImage: UIImageView!
    override func layoutSubviews() {
        self.layer.cornerRadius = 6
        layer.borderWidth = 2
    }
    
    func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        let imageCache = NSCache<NSString, UIImage>()
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(image, nil)
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    
                } else if let data = data, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(image, nil)
                } else {
                    completion(nil, error)
                }
            }
            
            task.resume()
        }
    }
}
