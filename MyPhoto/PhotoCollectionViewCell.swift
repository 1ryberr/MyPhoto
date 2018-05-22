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
}
