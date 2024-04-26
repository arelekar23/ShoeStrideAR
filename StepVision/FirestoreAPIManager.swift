//
//  SneaksAPIManager.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/23/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Shoes: Codable {
    let shoeName: String
    let brand: String
    let make: String
    let retailPrice: Double
    let description: String
    let image: String
}

struct CartItem {
    let shoe: Shoes
    var quantity: Int
}

class FirestoreAPIManager {
    static let shared = FirestoreAPIManager()
    private init() {
    }
    
    func fetchShoes(completion: @escaping (Result<[Shoes], Error>) -> Void) {
        let db = Firestore.firestore()
        let shoesCollection = db.collection("shoes")
        
        shoesCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var shoes: [Shoes] = []
                for document in querySnapshot!.documents {
                    do {
                        // Assuming Shoes is a Codable struct/model
                        let shoe = try document.data(as: Shoes.self)
                        shoes.append(shoe)
                    } catch let error {
                        completion(.failure(error))
                        return
                    }
                }
                completion(.success(shoes))
            }
        }
    }
    
    func addToCart(shoes: Shoes, quantity: Int, completion: @escaping (Result<Void, Error>, Bool) -> Void) {
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error), false)
            return
        }
        
        // Check if the shoe already exists in the cart
        let userDocument = userCollection.document(currentUser.uid)
        userDocument.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error), false)
                return
            }
            
            var updatedCart: [String: Int] = [:]
            
            if let cartData = document?.data()?["cart"] as? [String: Int] {
                updatedCart = cartData
            }
            
            if updatedCart.keys.contains(shoes.shoeName) {
                // Shoe already exists in the cart, update quantity
                updatedCart[shoes.shoeName]! += quantity
            } else {
                // Add new shoe to the cart
                updatedCart[shoes.shoeName] = quantity
            }
            
            // Update cart in Firestore
            userDocument.setData(["cart": updatedCart], merge: true) { error in
                if let error = error {
                    completion(.failure(error), false)
                    return
                }
                completion(.success(()), true)
            }
        }
    }
    
    func removeAllItemsFromCart(completion: @escaping (Result<Void, Error>, Bool) -> Void) {
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error), false)
            return
        }
        
        let userDocument = userCollection.document(currentUser.uid)
        userDocument.updateData(["cart": FieldValue.delete()]) { error in
            if let error = error {
                completion(.failure(error), false)
                return
            }
            completion(.success(()), true)
        }
    }

    
    func removeFromCart(shoes: Shoes, completion: @escaping (Result<Void, Error>, Bool) -> Void) {
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error), false)
            return
        }
        
        let userDocument = userCollection.document(currentUser.uid)
        userDocument.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error), false)
                return
            }
            
            var updatedCart: [String: Int] = [:]
            
            if let cartData = document?.data()?["cart"] as? [String: Int] {
                updatedCart = cartData
            }
            
            // Check if the shoe exists in the cart
            if updatedCart.keys.contains(shoes.shoeName) {
                // If quantity is greater than 1, decrement it
                if let quantity = updatedCart[shoes.shoeName], quantity > 1 {
                    updatedCart[shoes.shoeName]! -= 1
                } else {
                    // If quantity is 1, completely remove the key
                    updatedCart.removeValue(forKey: shoes.shoeName)
                }
            } else {
                // Shoe not found in the cart
                let error = NSError(domain: "Cart", code: -1, userInfo: [NSLocalizedDescriptionKey: "Shoe not found in the cart."])
                completion(.failure(error), false)
                return
            }
            
            // Update cart in Firestore
            if updatedCart.isEmpty {
                userDocument.updateData(["cart": FieldValue.delete()]) { error in
                    if let error = error {
                        completion(.failure(error), false)
                        return
                    }
                    completion(.success(()), true)
                }
            } else {
                userDocument.updateData(["cart": updatedCart]) { error in
                    if let error = error {
                        completion(.failure(error), false)
                        return
                    }
                    completion(.success(()), true)
                }
            }

        }
    }



    func fetchCart(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let db = Firestore.firestore()
        
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error))
            return
        }
        
        let userDocument = db.collection("users").document(currentUser.uid)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document does not exist."])
                completion(.failure(error))
                return
            }
            
            if let cartData = document.data()?["cart"] as? [String: Int] {
                // Fetch details of shoes from cart
                self.fetchShoesFromCart(cartData: cartData, completion: completion)
            } else {
                // If cart field is not found or is not in the expected format
                let error = NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cart data not found or invalid format."])
                completion(.failure(error))
            }
        }
    }

    func fetchShoesFromCart(cartData: [String: Int], completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let db = Firestore.firestore()
        let shoesCollection = db.collection("shoes")
        
        var cartItems: [CartItem] = []
        let dispatchGroup = DispatchGroup()
        
        for (shoeName, quantity) in cartData {
            dispatchGroup.enter()
            let query = shoesCollection.whereField("shoeName", isEqualTo: shoeName)
            query.getDocuments { (querySnapshot, error) in
                defer {
                    dispatchGroup.leave()
                }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found."])))
                    return
                }
                for document in documents {
                    do {
                        let shoe = try document.data(as: Shoes.self)
                        cartItems.append(CartItem(shoe: shoe, quantity: quantity))
                        
                    } catch {
                        completion(.failure(error))
                        return
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(cartItems))
        }
    }
}



//func fetchProducts(completion: @escaping (Result<[Shoes], Error>) -> Void) {
//        guard let url = URL(string: "http://localhost:3000/products") else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200 else {
//                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
//                return
//            }
//
//            if let data = data {
//                do {
//                    let decoder = JSONDecoder()
//                    let products = try decoder.decode([Shoes].self, from: data)
//                        .filter { !$0.description.isEmpty && !$0.shoeName.contains("Jersey") && !$0.shoeName.contains("Hood") && !$0.shoeName.contains("Sunglasses") && !$0.shoeName.contains("Louis Vuitton") && !$0.shoeName.contains("Tee") && !$0.shoeName.contains("Shorts") && !$0.shoeName.contains("Jacquemus") && !$0.shoeName.contains("Crocs") && !$0.shoeName.contains("Saint") && !$0.shoeName.contains("Slipper") && !$0.shoeName.contains("Slide") && !$0.shoeName.contains("Foam")}
//                    completion(.success(products))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
