//
//  FavCityTableViewCell.swift
//  MyPhoto
//
//  Created by Ryan Berry on 5/17/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit

class FavCityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var highsLabels: UILabel!
    @IBOutlet weak var lowsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        hide()
        tempLabel.text = "0"
        humidityLabel.text = "0"
        highsLabels.text = "0"
        lowsLabel.text = "0"
    }
    
    func animate(){
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.7)
        layer.transform = CATransform3DIdentity
        alpha = 1
        
        UIView.commitAnimations()
    }
    
    func hide() {
        alpha = 0
        layer.transform = CATransform3DMakeRotation((90.0 * .pi) / 180,0,0.3,0.2)
        layer.anchorPoint = CGPoint(x: 0, y: 0)
    }
    
    
}
