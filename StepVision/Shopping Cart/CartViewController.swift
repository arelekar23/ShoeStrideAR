//
//  CartTableViewController.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/25/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit
import StripePaymentSheet
import FirebaseAuth

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var totalView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var placeOrderButton: UIButton!
    var finalPrice: Int?
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://shoestridear-backend-aeee3e6df9d2.herokuapp.com/create-payment-intent")!
    
    let firestoreApi = FirestoreAPIManager.shared
    var cartItems: [CartItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
        updateEmptyCartMessage()
        totalView.layer.shadowColor = UIColor.darkGray.cgColor
        totalView.layer.shadowOpacity = 0.5
        totalView.layer.shadowOffset = CGSize(width: 0, height: 2)
        totalView.layer.shadowRadius = 5
        totalView.layer.cornerRadius = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.fetchProducts()
            self.updateEmptyCartMessage()
        }
    }

    @IBAction func placeOrderTapped(_ sender: UIButton) {
        paymentSheet?.present(from: self) { paymentResult in
            switch paymentResult {
            case .completed:
                self.cartItems.removeAll()
                self.fetchProducts()
                self.updateEmptyCartMessage()
                self.tableView.reloadData()
                self.updateTotalPrice()
                self.handleOrderCompletion()
            case .canceled:
                self.handleOrderCancellation()
            case .failed(let error):
                self.handleOrderFailure(error: error)
            }
        }
    }
    
    func handleOrderCompletion() {
        self.placeOrderButton.isEnabled = false
        self.emptyCart()
        let alertController = UIAlertController(title: "Order Successful", message: "Your order has been successfully placed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        print("Your order is confirmed")
    }

    func handleOrderCancellation() {
        print("Canceled!")
        let alertController = UIAlertController(title: "Order Unsuccessful", message: "Your order failed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        print("Your order is cancelled")
    }

    func handleOrderFailure(error: Error) {
        print("Payment failed: \(error)")
        let alertController = UIAlertController(title: "Order Fail", message: "Your order failed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        print("Your order is Failed")
    }
    
    func apiCall() {
        var userEmail = Auth.auth().currentUser?.email
        let cartContent: [String: Any?] = ["amount": finalPrice!*100, "email": userEmail]
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cartContent)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerId = json["customerId"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["clientSecret"] as? String,
                  let publishableKey = json["publishableKey"] as? String,
                  let self = self else {
                // Handle error
                return
            }
            
            STPAPIClient.shared.publishableKey = publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "ShoeStride.Inc"
            configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
            configuration.allowsDelayedPaymentMethods = true
            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            DispatchQueue.main.async {
                self.placeOrderButton.isEnabled = true
            }
        })
        task.resume()
    }
    
    func fetchProducts() {
        firestoreApi.fetchCart { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedCartItems):
                self.cartItems = fetchedCartItems
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateTotalPrice()
                    self.apiCall()
                }
            case .failure(let error):
                print("Error fetching cart:", error)
            }
        }
    }
    func emptyCart(){
        firestoreApi.removeAllItemsFromCart { [weak self] result, success in
            guard let self = self else { return }
            switch result {
            case .success():
                self.cartItems = []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(_):
                print("Error empltying cart")
            }
        }
    }

    func updateTotalPrice() {
        finalPrice = 0
        for cartItem in cartItems {
            finalPrice! += Int(cartItem.shoe.retailPrice) * cartItem.quantity
        }
        self.totalPrice.text = "$ " + String(Double(finalPrice!))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return cartItems.isEmpty ? 0 : cartItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let cartItem = cartItems[indexPath.section] // Access cartItem from cartItems
        cell.setup(with: ShoeCell(label: cartItem.shoe.shoeName, price: cartItem.shoe.retailPrice, image: UIImage(named: cartItem.shoe.image) ?? UIImage(), description: cartItem.shoe.description, quantity: cartItem.quantity))
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        // Set the height for each section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 10 // Adjust this value to set the desired space between sections
   }

    // Provide a custom view for each section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear // Set the background color of the header view
        
        return headerView
    }
    
    func updateEmptyCartMessage() {
        if cartItems.isEmpty {
            // Create a label to display the empty cart message
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = "Your cart is lonely, add something 😢"
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()

            // Set the label as the background view of the table view
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .none // Hide separators
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
}


extension CartViewController: CartTableViewCellDelegate {
    func addCartButtonTapped(for cell: CartTableViewCell) {
        // Handle add button tapped
        if let indexPath = tableView.indexPath(for: cell) {
            let cartItem = cartItems[indexPath.section] // Access the corresponding cart item
            
            // Call addToCart method with the updated quantity
            firestoreApi.addToCart(shoes: cartItem.shoe, quantity: 1) { [weak self] result, success in
                guard let self = self else { return }
                switch result {
                case .success:
                    if success {
                        DispatchQueue.main.async {
                            self.fetchProducts()
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            self.updateTotalPrice()
                        }
                    } else {
                        print("Failed to update cart")
                    }
                case .failure(let error):
                    print("Error adding to cart:", error)
                }
            }
        }
    }


    
    func removeCartButtonTapped(for cell: CartTableViewCell) {
        // Handle remove button tapped
        if let indexPath = tableView.indexPath(for: cell) {
            let cartItem = cartItems[indexPath.section] // Access the corresponding cart item
            
            // Call removeFromCart method to remove the item from the cart
            firestoreApi.removeFromCart(shoes: cartItem.shoe) { [weak self] result, success in
                guard let self = self else { return }
                switch result {
                case .success:
                    if success {
                        DispatchQueue.main.async {
                            self.fetchProducts() // Refresh cart after removing item
                            self.updateEmptyCartMessage()
                            self.tableView.reloadData()
//                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            self.updateTotalPrice()
                        }
                    } else {
                        print("Failed to update cart")
                    }
                case .failure(let error):
                    print("Error removing from cart:", error)
                }
            }
        }
    }

}
