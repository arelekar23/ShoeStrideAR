//
//  HomeViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/10/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import UIKit


class HomeVC:  UIViewController, UISearchBarDelegate {


    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tabButtonsView: UIView!
    
    @IBOutlet var cellContentView: UIView!
    
    let firestoreApi = FirestoreAPIManager.shared
    var shoes: [Shoes] = []
    var filteredShoes: [Shoes] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredShoeLabels = [String]()
    var isSearching = false
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureSearchBar()
        fetchProducts()
        tabButtonsView.layer.shadowColor = UIColor.darkGray.cgColor
        tabButtonsView.layer.shadowOpacity = 0.5
        tabButtonsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabButtonsView.layer.shadowRadius = 5
        tabButtonsView.layer.cornerRadius = 15
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchProducts()
    }
    
    @IBAction func cartButtonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "ToProfileVC", sender: nil)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "ToProfileVC", sender: nil)
    }
    
    func fetchProducts() {
        
        firestoreApi.fetchShoes { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self.shoes = products
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching products:", error)
            }
        }
    }

        
//    func configureSearchBar() {
//        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
//            searchTextField.backgroundColor = .white
//            searchTextField.textColor = .black
//            if let placeholder = searchTextField.placeholder {
//                let attributedString = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
//                searchTextField.attributedPlaceholder = attributedString
//            }
//            if let searchIcon = searchTextField.leftView as? UIImageView {
//                searchIcon.tintColor = .black
//            }
//        }
//    }
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        filteredShoeLabels = shoeLabels.filter({ $0.lowercased().contains(searchText.lowercased()) })
//        isSearching = !searchText.isEmpty
//        collectionView.reloadData()
//    }
    
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredShoes.count : shoes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let shoe = isSearching ? filteredShoes[indexPath.item] : shoes[indexPath.item]
        cell.setup(with: ShoeCell(label: shoe.shoeName, price: shoe.retailPrice, image: UIImage(named: shoe.image) ?? UIImage(), description: shoe.description, quantity: 1))
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 40) / 2
        return CGSize(width: size, height: size + 60)
        
//        return CGSize(width: 200, height: 214)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           let padding: CGFloat = 10
           return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShoe = shoes[indexPath.row]
        performSegue(withIdentifier: "ToShoeDetailsVC", sender: selectedShoe)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToShoeDetailsVC" {
           if let indexPath = collectionView.indexPathsForSelectedItems?.first {
               let selectedShoe = shoes[indexPath.row]
               // Pass the selected shoe label to the next view controller
               if let shoeDetailsVC = segue.destination as? ShoeDetailsVC {
                   shoeDetailsVC.shoe = selectedShoe
               }
           }
       }
    }
}


