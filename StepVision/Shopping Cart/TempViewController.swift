//
//  TempViewController.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/26/24.
//  Copyright © 2024 Snap. All rights reserved.
//

//
//  CartViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/10/24.
//  Copyright ©️ 2024 Snap. All rights reserved.
//

//import Foundation
//import UIKit
//import StripePaymentSheet
//
//class TempViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HomeViewControllerDelegate {
//    @IBOutlet weak var checkoutButton: UIButton!
//    weak var delegate: HomeViewControllerDelegate?
//    var paymentSheet: PaymentSheet?
//  
//    
//    func didSelectItem(_ item: ShoeCell) {
//        itemsInCart.append(item)
//        print(itemsInCart)
//        cartTableView.reloadData()
//        
//    }
//    
//    @IBOutlet weak var cartTableView: UITableView!
//    
//    @IBOutlet weak var totalPriceLabel: UIBarButtonItem!
//    
//    @IBAction func checkoutButtonClicked(_ sender: UIButton) {
//        paymentSheet?.present(from: self) { paymentResult in
//            // MARK: Handle the payment result
//            print("inside button present sheet")
//            switch paymentResult {
//            case .completed:
//                print("Your order is confirmed")
//            case .canceled:
//                print("Canceled!")
//            case .failed(let error):
//                print("Payment failed: \(error)")
//            }
//        }
//    }
//    var itemsInCart : [ShoeCell] = []
//    let backendCheckoutUrl = URL(string: "https://shoestridear-backend-aeee3e6df9d2.herokuapp.com/create-payment-intent")!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        cartTableView.reloadData()
//        cartTableView.delegate = self
//        cartTableView.dataSource = self
//        cartTableView.separatorStyle = .none
//        updateTotalPriceLabel()
//        let backButton = UIBarButtonItem()
//        backButton.title = "Back"
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
//        
//        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
//        var request = URLRequest(url: backendCheckoutUrl)
//        request.httpMethod = "POST"
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
//                  let customerId = json["customer"] as? String,
//                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
//                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
//                  let publishableKey = json["publishableKey"] as? String,
//                  let self = self else {
//                // Handle error
//                return
//            }
//            
//            STPAPIClient.shared.publishableKey = publishableKey
//            // MARK: Create a PaymentSheet instance
//            var configuration = PaymentSheet.Configuration()
//            configuration.merchantDisplayName = "Example, Inc."
//            configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
//            // Set `allowsDelayedPaymentMethods` to true if your business handles
//            // delayed notification payment methods like US bank accounts.
//            configuration.allowsDelayedPaymentMethods = true
//            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
//            
//            DispatchQueue.main.async {
//                self.checkoutButton.isEnabled = true
//            }
//        })
//        task.resume()
//        
//    }
//    @objc
//    func didTapCheckoutButton() {
//        // MARK: Start the checkout process
//        paymentSheet?.present(from: self) { paymentResult in
//            // MARK: Handle the payment result
//            print("inside button present sheet")
//            switch paymentResult {
//            case .completed:
//                print("Your order is confirmed")
//            case .canceled:
//                print("Canceled!")
//            case .failed(let error):
//                print("Payment failed: \(error)")
//            }
//        }
//    }
//    func updateTotalPriceLabel() {
//        let totalPrice = itemsInCart.reduce(0.0) { $0 + $1.price }
//        totalPriceLabel.title = String(format: "Total Price: $%.2f", totalPrice)
//    }
//    
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row % 2 == 0 {
//            return 100
//        } else {
//            return 30
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        itemsInCart.count * 2
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UITableViewCell
//        if indexPath.row % 2 == 0 {
//            // For even rows, use a normal cell with item data
//            let itemCell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath)
//            let item = itemsInCart[indexPath.row / 2]
//            itemCell.imageView?.image = item.image
//            itemCell.imageView?.contentMode = .scaleToFill
//            itemCell.textLabel?.text = item.label
//            let deleteButton = UIButton(type: .system)
//            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
//            deleteButton.tintColor = .red
//            deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
//            deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//            itemCell.accessoryView = deleteButton
//            
//            cell = itemCell
//        } else {
//            // For odd rows, use an empty cell
//            cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
//            cell.textLabel?.text = ""
//            cell.imageView?.image = nil
//            cell.accessoryView = nil
//        }
//        return cell
//    }
//    
//    @objc func deleteButtonTapped(_ sender: UIButton) {
//        // Get the index path of the cell containing the delete button
//        if let cell = sender.superview as? UITableViewCell,
//           let indexPath = cartTableView.indexPath(for: cell) {
//            // Adjust the index to map it to the index of itemsInCart
//            let adjustedIndex = indexPath.row / 2
//            // Remove the item from the data source
//            itemsInCart.remove(at: adjustedIndex)
//            // Reload the table view to reflect the changes
//            cartTableView.reloadData()
//            updateTotalPriceLabel()
//        }
//    }
//}
