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
import FirebaseStorage

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
    
    func fetchPartnerGroupId(forShoe shoeName: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let db = Firestore.firestore()
        let shoesCollection = db.collection("shoes")
        
        let query = shoesCollection.whereField("shoeName", isEqualTo: shoeName)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success(nil))
                return
            }
            
            if let document = documents.first {
                let partnerGroupId = document["partnerGroupId"] as? String
                completion(.success(partnerGroupId))
            } else {
                completion(.success(nil))
            }
        }
    }

    
    func fetchPurchasedCount(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error))
            return
        }

        let db = Firestore.firestore()
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

            if let purchasedCount = document.data()?["purchased"] as? Int {
                completion(.success(purchasedCount))
            } else {
                let error = NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Purchased count not found or invalid format."])
                completion(.failure(error))
            }
        }
    }

    func incrementFavoritesCount(for shoe: Shoes, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)
        
        // Update the favorites count for the shoe in the user's document
        userDocument.updateData(["favorites": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                print("Error incrementing favorites count: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Favorites count incremented successfully.")
                completion(true)
            }
        }
    }

    func decrementFavoritesCount(for shoe: Shoes, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)
        
        // Update the favorites count for the shoe in the user's document
        userDocument.updateData(["favorites": FieldValue.increment(Int64(-1))]) { error in
            if let error = error {
                print("Error decrementing favorites count: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Favorites count decremented successfully.")
                completion(true)
            }
        }
    }
    
    func updateFavoriteShoes(shoeName: String, isFavorite: Bool, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)

        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard var userData = document?.data(), var favoriteShoes = userData["favoriteShoes"] as? [String] else {
                print("Favorite shoes not found or invalid format.")
                completion(false)
                return
            }

            if isFavorite {
                // Append shoeName to favoriteShoes array if it's not already there
                if !favoriteShoes.contains(shoeName) {
                    favoriteShoes.append(shoeName)
                    userData["favoriteShoes"] = favoriteShoes
                    userDocument.setData(userData) { error in
                        if let error = error {
                            print("Error updating favorite shoes: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Favorite shoes updated successfully.")
                            completion(true)
                        }
                    }
                } else {
                    // Shoe already exists in favoriteShoes array
                    print("Shoe already exists in favorite shoes.")
                    completion(true)
                }
            } else {
                // Remove shoeName from favoriteShoes array if it exists
                if let index = favoriteShoes.firstIndex(of: shoeName) {
                    favoriteShoes.remove(at: index)
                    userData["favoriteShoes"] = favoriteShoes
                    userDocument.setData(userData) { error in
                        if let error = error {
                            print("Error updating favorite shoes: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Favorite shoes updated successfully.")
                            completion(true)
                        }
                    }
                } else {
                    // Shoe does not exist in favoriteShoes array
                    print("Shoe does not exist in favorite shoes.")
                    completion(true)
                }
            }
        }
    }

    func isShoeInFavorites(shoeName: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)

        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let userData = document?.data(), let favoriteShoes = userData["favoriteShoes"] as? [String] else {
                print("Favorite shoes not found or invalid format.")
                completion(false)
                return
            }

            // Check if the shoeName is in the favoriteShoes array
            let isInFavorites = favoriteShoes.contains(shoeName)
            completion(isInFavorites)
        }
    }

    func fetchOrders(completion: @escaping ([Order]?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching orders document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist.")
                completion(nil)
                return
            }
            
            // Parse orders array
            if let ordersArray = document.data()?["orders"] as? [[String: Any]] {
                var orders: [Order] = []
                for orderData in ordersArray {
                    if let description = orderData["description"] as? String,
                       let image = orderData["image"] as? String,
                       let price = orderData["price"] as? Double,
                       let quantity = orderData["quantity"] as? Int,
                       let shoeName = orderData["shoeName"] as? String,
                       let timestamp = orderData["timestamp"] as? TimeInterval {
                       let order = Order(description: description,
                                               image: image,
                                               price: price,
                                               quantity: quantity,
                                               shoeName: shoeName,
                                               timestamp: timestamp)
                       orders.append(order)
                    }
                }
                completion(orders)
            } else {
                print("No orders found.")
                completion(nil)
            }
        }
    }

    
    func fetchFavoritesCount(completion: @escaping (Int?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user.")
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist.")
                completion(nil)
                return
            }
            
            if let favoritesCount = document.data()?["favorites"] as? Int {
                completion(favoritesCount)
            } else {
                print("Favorites count not found or invalid format.")
                completion(nil)
            }
        }
    }

    
    func addOrder(orderData: [String: Any], Quantity: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])
            completion(.failure(error))
            return
        }
        
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)
        
        // Increment the 'purchased' field by the total quantity from cart
        userDocument.updateData([
            "orders": FieldValue.arrayUnion([orderData]),
            "purchased": FieldValue.increment(Int64(Quantity))
        ]) { error in
            if let error = error {
                // If there's an error, return failure
                completion(.failure(error))
            } else {
                // If successful, return success
                completion(.success(()))
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


    func returnCurrentUserProfileImageUrl(completion: @escaping (String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            // No logged-in user, return nil
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { document, error in
            if let error = error {
                // Handle the error
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                // User document exists, check for profile image URL
                if let profileImageURL = document.data()?["profileImageURL"] as? String {
                    // Profile image URL found, return it
                    completion(profileImageURL)
                } else {
                    // Profile image URL not found
                    print("Profile image URL not found in user document")
                    completion(nil)
                }
            } else {
                // User document does not exist
                print("User document does not exist")
                completion(nil)
            }
        }
    }

    
    func returnCurrentUserName(completion: @escaping (String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion("")
            return
        }

        if let displayName = currentUser.displayName {
            // If display name is available, return it
            completion(displayName)
        } else {
            // Fetch the name from Firestore
            let db = Firestore.firestore()
            let userCollection = db.collection("users").document(currentUser.uid)

            userCollection.getDocument { (document, error) in
                if let error = error {
                    // Handle the error
                    print("Error fetching user document: \(error.localizedDescription)")
                    completion("")
                    return
                }

                if let document = document, document.exists {
                    if let userData = document.data(),
                       let userName = userData["username"] as? String {
                        // Use the fetched user name
                        completion(userName)
                    } else {
                        // Name not found in user document
                        print("Name not found in user document")
                        completion("")
                    }
                } else {
                    // User document does not exist
                    print("User document does not exist")
                    completion("")
                }
            }
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
    
    func uploadImage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        // Upload the file to the path "images/[UUID].jpg"
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                if let error = error {
                    // Uh-oh, an error occurred!
                    completion(.failure(error))
                }
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    completion(.failure(error))
                } else if let downloadURL = url {
                    // Get the download URL for the image
                    let urlString = downloadURL.absoluteString
                    
                    // Update the Firestore document with the image URL
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
                    userRef.setData(["profileImageURL": urlString], merge: true) { error in
                        if let error = error {
                            // Handle error
                            completion(.failure(error))
                        } else {
                            // Success, return image URL
                            completion(.success(urlString))
                        }
                    }
                }
            }
        }
        
        // Observe changes in status of the upload
        uploadTask.observe(.progress) { snapshot in
            // Upload progress
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                // Handle upload failure
                completion(.failure(error))
            }
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
