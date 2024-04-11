//
//  HomeViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/10/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import Foundation
import UIKit
@available(iOS 13.0, *)
class HomeViewController:  UIViewController, UISearchBarDelegate, UITabBarDelegate{
    
    @IBOutlet var shoeCollectionView: UICollectionView!
    @IBOutlet weak var bottonTabBar: UITabBar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var shoeLabels = ["Nike1","Nike2","Nike3","Nike4","Nike5","Nike6","Nike7","Nike8","Nike9","Nike10"]
    var shoePrices = [35.00,35.00,35.00,35.00,35.00,35.00,35.00,35.00,35.00,35.00]
    var shoeImages = ["Nike1","Nike2","Nike3","Nike4","Nike5","Nike6","Nike7","Nike8","Nike9","Nike10"]
    var filteredShoeLabels = [String]()
        var isSearching = false
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoeCollectionView.dataSource = self
        shoeCollectionView.delegate = self
        shoeCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        searchBar.delegate = self
        searchBar.clipsToBounds = true
        searchBar.barTintColor = .systemBackground
        let hour = Calendar.current.component(.hour, from: Date())
        var greeting = ""
        switch hour {
        case 0..<12:
            greeting = "Good Morning,"
        case 12..<17:
            greeting = "Good Afternoon,"
        default:
            greeting = "Good Evening,"
        }
        self.navigationItem.title = greeting
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        bottonTabBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredShoeLabels = shoeLabels.filter({ $0.lowercased().contains(searchText.lowercased()) })
        isSearching = !searchText.isEmpty
        shoeCollectionView.reloadData()
    }
    
}

@available(iOS 13.0, *)
extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        switch index {
        case 0: // Home tab
            break // Already in home
        case 1: // Cart tab
            if let cartVC = storyboard?.instantiateViewController(withIdentifier: "CartViewController") {
                navigationController?.pushViewController(cartVC, animated: true)
            }
        case 2: // Person tab
            if let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") {
                navigationController?.pushViewController(profileVC, animated: true)
            }
        default:
            break
        }
    }
}


@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredShoeLabels.count : shoeLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = shoeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let label = isSearching ? filteredShoeLabels[indexPath.row] : shoeLabels[indexPath.row]
        let price = isSearching ? shoePrices[shoeLabels.firstIndex(of: filteredShoeLabels[indexPath.row]) ?? 0] : shoePrices[indexPath.row]
        let image = isSearching ? UIImage(named: shoeImages[shoeLabels.firstIndex(of: filteredShoeLabels[indexPath.row]) ?? 0]) : UIImage(named: shoeImages[indexPath.row])
        cell.setup(with: ShoeCell(label: label, price: price, image: image ?? UIImage()))
        return cell
    }
}

@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           let padding: CGFloat = 10
           return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
       }
}

