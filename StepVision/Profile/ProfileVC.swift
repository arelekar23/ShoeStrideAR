//
//  HomeViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileView: UIView!
    
    let profileItems = ["My Orders", "Returns", "Invite Friends", "Payments", "Delete Account", "Help", "About", "Logout"]
    let profileItemsIcons = ["tag", "return", "person.fill.badge.plus", "dollarsign", "person", "questionmark.circle", "info","rectangle.portrait.and.arrow.forward"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.superview?.bringSubviewToFront(profileView)
        profileView.superview?.bringSubviewToFront(profileImage)
        // Make the profileImage circular with a border
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.white.cgColor // Change border color as needed
        
        // Set the profileImage's image
        profileImage.image = UIImage(systemName: "person.fill")
        
        
        profileView.layer.shadowColor = UIColor.darkGray.cgColor
        profileView.layer.shadowOpacity = 0.5
        profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileView.layer.shadowRadius = 5
        profileView.layer.cornerRadius = 15
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let text = profileItems[indexPath.row]
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 17)]
        cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: attributes)
        if let icon = UIImage(systemName: profileItemsIcons[indexPath.row]) {
            cell.imageView?.image = icon
        }
        if(!text.elementsEqual("Logout")){
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        return cell
    }
}
