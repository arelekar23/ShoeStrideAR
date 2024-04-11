//
//  HomeViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//
import UIKit

@available(iOS 13.0, *)
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    let profileItems = ["","", "", "My Orders", "Returns", "Invite Friends", "Payments", "Delete Account", "Help", "About", "Logout"]
    let profileItemsIcons = ["","", "", "tag", "return", "person.fill.badge.plus", "dollarsign", "person", "questionmark.circle", "info","rectangle.portrait.and.arrow.forward"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 1{
            return 80
        }else {
            return 50
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 22)]
            cell.textLabel?.attributedText = NSAttributedString(string: "Amar Nagargoje", attributes: attributes)
            cell.detailTextLabel?.text = "amardnagargoje@gmail.com"
            cell.detailTextLabel?.font = UIFont(name:"", size: 12)
            cell.imageView?.image = UIImage(named: "Profile")
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.clipsToBounds = true
            cell.imageView?.frame.size = CGSize(width: 40, height: 40)
            cell.imageView?.layer.cornerRadius = 40
            return cell
        }
        else if indexPath.row == 0 || indexPath.row == 2 {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            return cell
        } 
        else {
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

}
