//
//  ViewOrdersVC.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/27/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import UIKit

class ViewOrdersVC: UITableViewController {

    @IBOutlet weak var ordersTableView: UITableView!
    
    var orders: [Order] = []
    let firestoreApi = FirestoreAPIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
        fetchOrdersFromFirestore()
    }
    
    
    func fetchOrdersFromFirestore() {
        firestoreApi.fetchOrders { [weak self] (orders) in
            guard let self = self else { return }
            if let orders = orders {
                self.orders = orders
                DispatchQueue.main.async {
                    self.ordersTableView.reloadData()
                }
            } else {
                print("Failed to fetch orders.")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
        let order = orders[indexPath.row]
        
        // Display order details
        cell.shoeNameLabel.text = order.shoeName
        cell.qtyLabel.text = "\(order.quantity)"
        cell.orderTotalLabel.text = "$\(order.price * Double(order.quantity))"
        cell.shoeImage.image =  UIImage(named: order.image)
        // Convert timestamp to date
        let orderDate = Date(timeIntervalSince1970: order.timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: orderDate)
        cell.orderPlaceOnLabel.text = dateString
        
        return cell
    }
    
}

class OrderCell: UITableViewCell {
    @IBOutlet weak var shoeImage: UIImageView!
    @IBOutlet weak var shoeNameLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var orderPlaceOnLabel: UILabel!
}
