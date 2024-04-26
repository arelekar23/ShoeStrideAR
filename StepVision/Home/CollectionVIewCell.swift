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
    
    @IBOutlet var shoeName: UILabel!
    @IBOutlet var shoePrice: UILabel!
    @IBOutlet var shoeImageView: UIImageView!
    @IBOutlet var shoeBg: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add border
//        layer.borderWidth = 0.5
//        layer.borderColor = UIColor.lightGray.cgColor
        // Round corners of the cell
//        layer.cornerRadius = 10
//        layer.masksToBounds = true
//        layer.shadowColor = UIColor.gray.cgColor
//        layer.shadowRadius = 20
        
        contentView.layer.cornerRadius = 8 // Apply corner radius to the content view
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
//        layer.cornerRadius = 40
        layer.masksToBounds = false
        
        
        createBg()
    }
        
    override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    bringToFront()
                } else {
                    sendToBack()
                }
            }
        }
        
        func bringToFront() {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.layer.zPosition = 1
            }
        }
        
        func sendToBack() {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.layer.zPosition = 0
            }
        }
    
    func setup(with shoe: ShoeCell) {
        shoeName.text = shoe.label
        shoePrice.text = "$ " + String(shoe.price)
        shoeImageView.image = shoe.image
    }
    
    func createBg() {
        // Set the content mode of the shoeImageView to aspect fill
        shoeImageView.contentMode = .scaleAspectFill
        // Clip the content of the shoeImageView to its bounds
        shoeImageView.clipsToBounds = false
        
        // Calculate the smaller size for the shoeImageView
        let smallerSize = CGSize(width: contentView.bounds.width * 0.4, height: contentView.bounds.height * 0.4)
        // Calculate the origin point for the shoeImageView relative to shoeBg's bounds
        let origin = CGPoint(x: (contentView.bounds.width - smallerSize.width) / 2 - 24, y: (contentView.bounds.height - smallerSize.height) / 2 + 20)
        // Set the frame of the shoeImageView relative to shoeBg's bounds
        shoeImageView.frame = CGRect(origin: origin, size: smallerSize)
        
        // Rotate the image by 45 degrees clockwise and mirror horizontally
        shoeImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3.7 / 4) // Rotate by 45 degrees
        shoeImageView.transform = shoeImageView.transform.scaledBy(x: 1, y: -1)
        
        contentView.superview?.addSubview(shoeImageView)
        contentView.superview?.bringSubviewToFront(shoeImageView)
    }

    

}




