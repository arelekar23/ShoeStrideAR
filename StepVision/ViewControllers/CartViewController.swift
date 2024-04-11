//
//  CartViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/10/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet weak var cartTableView: UITableView!
    
    @IBOutlet weak var totalPriceLabel: UIBarButtonItem!
    
    var itemsInCart : [ShoeCell] = []
    let shoes: [ShoeCell] = [
        ShoeCell(label: "Nike6", price: 35.00, image: UIImage(named: "Nike6")!),
        ShoeCell(label: "Nike1", price: 35.00, image: UIImage(named: "Nike1")!),
        ShoeCell(label: "Nike9", price: 35.00, image: UIImage(named: "Nike9")!)
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsInCart = shoes
        cartTableView.delegate = self
        cartTableView.dataSource = self
        cartTableView.separatorStyle = .none
        updateTotalPriceLabel()
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
            
    }
    
    func updateTotalPriceLabel() {
           let totalPrice = itemsInCart.reduce(0.0) { $0 + $1.price }
        totalPriceLabel.title = String(format: "Total Price: $%.2f", totalPrice)
       }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 100
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsInCart.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.row % 2 == 0 {
            // For even rows, use a normal cell with item data
            let itemCell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath)
            let item = itemsInCart[indexPath.row / 2]
            itemCell.imageView?.image = item.image
            itemCell.imageView?.contentMode = .scaleToFill
            itemCell.textLabel?.text = item.label
            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = .red
            deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            itemCell.accessoryView = deleteButton

            cell = itemCell
        } else {
            // For odd rows, use an empty cell
            cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell.textLabel?.text = ""
            cell.imageView?.image = nil
            cell.accessoryView = nil
        }
        return cell
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        // Get the index path of the cell containing the delete button
        if let cell = sender.superview as? UITableViewCell,
            let indexPath = cartTableView.indexPath(for: cell) {
            // Adjust the index to map it to the index of itemsInCart
            let adjustedIndex = indexPath.row / 2
            // Remove the item from the data source
            itemsInCart.remove(at: adjustedIndex)
            // Reload the table view to reflect the changes
            cartTableView.reloadData()
            updateTotalPriceLabel()
        }
    }

}
