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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = profileItems[indexPath.row]
        
        switch selectedOption {
        case "Help":
            let helpMessage = """
            If you need any assistance or have any questions about our app, we're here to help!

            Our support team is dedicated to providing you with the best possible assistance. Whether you have questions about how to use a feature, encounter an issue, or simply want to provide feedback, we're always happy to hear from you.

            For support or assistance, please feel free to email us at amargithub@gmail.com. Our team will get back to you as soon as possible.

            Thank you for using our app!
            """
            
            let alert = UIAlertController(title: "Help", message: helpMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case "About":
            let aboutMessage = """
        About Our Project: Augmented Reality Shoe Fitting Mobile App
            Team:

        Amar Nagargoje
        Adwait Relekar
        
        Introduction:

        The rise of online shopping has transformed retail, but one challenge remains: the inability to try on shoes virtually. Our solution bridges this gap by leveraging AR to provide an immersive and interactive shoe fitting experience. Users can explore a diverse catalog of shoes, visualize them on their feet in real-time, and make informed purchase decisions from the comfort of their homes.

        Key Features:

        Augmented Reality Shoe Visualization: Experience shoes in AR, overlaying digital models onto your feet for a realistic preview.
        Extensive Shoe Catalog: Discover a wide range of styles, brands, and sizes curated from partnering retailers.
        Size Recommendation: Utilize machine learning algorithms to find the perfect fit based on your foot dimensions.
        Social Sharing: Share your virtual try-on experiences with friends and followers, fostering engagement and recommendations.
        Wishlist and Favorites: Save your favorite shoes for future consideration and easy access.
        Complexity and Technical Requirements:

        Developing our app involves tackling various technical challenges, including AR integration, realistic shoe visualization, intuitive user interaction, robust backend infrastructure, and secure payment gateway integration. Our team's expertise ensures we address these complexities effectively to deliver a seamless user experience.

        Team Requirements:

        To execute this project successfully, our team comprises two individuals with specialized skill sets:

        AR Developer: Expertise in AR frameworks, 3D rendering, and computer vision.
        Full-Stack Developer: Proficiency in mobile app development, web development, payment gateway integration, and database management.
        Conclusion:

        Our AR shoe fitting app represents a groundbreaking innovation in online shopping, offering users an unparalleled way to shop for shoes virtually. With a dedicated team and advanced technologies, we're committed to delivering a high-quality app that meets the evolving needs of modern consumers.
        """
            let alert = UIAlertController(title: "About", message: aboutMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            break
        }

    }
}
