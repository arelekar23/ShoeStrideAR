//
//  CartTableViewCell.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/25/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    weak var delegate: CartTableViewCellDelegate?
    
    @IBOutlet var shoeName: UILabel!
    @IBOutlet var shoePrice: UILabel!
    @IBOutlet var shoeImageView: UIImageView!
    @IBOutlet var shoeBg: UIView!
    @IBOutlet var cellView: UIView!
    @IBOutlet var shoeQuantity: UILabel!
    @IBOutlet var addButtonTapped: UIButton!
    @IBOutlet var removeButtonTapped: UIButton!
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 8 // Apply corner radius to the content view
        cellView.layer.masksToBounds = true
//        cellView.layer.borderWidth = 0.4
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellView.layer.shadowRadius = 4
        cellView.layer.masksToBounds = false
        
        shoeBg.layer.cornerRadius = 8
        
        
        createBg()
    }

    @IBAction func removeButtonTapped(_ sender: UIButton) {
        delegate?.removeCartButtonTapped(for: self)
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
        delegate?.addCartButtonTapped(for: self)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with shoe: ShoeCell) {
        shoeName.text = shoe.label
        shoePrice.text = "$ " + String(shoe.price)
        shoeImageView.image = shoe.image
        shoeQuantity.text = "\(shoe.quantity)"
    }
    
    func createBg() {
        
        let circleLayer = CAShapeLayer()
        shoeBg.frame = shoeBg.bounds

        // Calculate the center of the shoeBg
        let centerX = shoeBg.bounds.midX
        let centerY = shoeBg.bounds.midY

        // Set the radius of the circle (adjust as needed)
        let radius: CGFloat = 40.0

        // Create a circle path
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)

        circleLayer.path = circlePath.cgPath
//        shoeBg.layer.mask = circleLayer
        
//         Set the content mode of the shoeImageView to aspect fill
        shoeImageView.contentMode = .scaleAspectFill
//         Clip the content of the shoeImageView to its bounds
        shoeImageView.clipsToBounds = false
        
        // Rotate the image by 45 degrees clockwise and mirror horizontally
        shoeImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3.7 / 4) // Rotate by 45 degrees
        shoeImageView.transform = shoeImageView.transform.scaledBy(x: 1, y: -1)
        
        shoeBg.addSubview(shoeImageView)

    }

}


protocol CartTableViewCellDelegate: AnyObject {
    func addCartButtonTapped(for cell: CartTableViewCell)
    func removeCartButtonTapped(for cell: CartTableViewCell)
}
