//
//  SneaksAPIManager.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/23/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Shoes: Codable {
    let shoeName: String
    let brand: String
    let make: String
    let retailPrice: Double
    let description: String
    let image: String
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
    
    func fetchProducts(completion: @escaping (Result<[Shoes], Error>) -> Void) {
            guard let url = URL(string: "http://localhost:3000/products") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    return
                }

                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let products = try decoder.decode([Shoes].self, from: data)
                            .filter { !$0.description.isEmpty && !$0.shoeName.contains("Jersey") && !$0.shoeName.contains("Hood") && !$0.shoeName.contains("Sunglasses") && !$0.shoeName.contains("Louis Vuitton") && !$0.shoeName.contains("Tee") && !$0.shoeName.contains("Shorts") && !$0.shoeName.contains("Jacquemus") && !$0.shoeName.contains("Crocs") && !$0.shoeName.contains("Saint") && !$0.shoeName.contains("Slipper") && !$0.shoeName.contains("Slide") && !$0.shoeName.contains("Foam")}
                        completion(.success(products))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
}
