//
//  CollectionViewCell.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/10/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import UIKit
class CollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var shoePrice: UILabel!
    @IBOutlet weak var shoeLabel: UILabel!
    @IBOutlet weak var shoeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add border
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        
        // Round corners
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func setup(with shoe: ShoeCell) {
        shoeLabel.text = shoe.label
        shoePrice.text = " $ " + String(shoe.price)
        shoeImageView.image = shoe.image
      }
}
