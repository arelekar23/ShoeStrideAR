//
//  HomeViewController.swift
//  StepVision
//
//  Created by Amar Nagargoje on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var profileName: UILabel!
    let firestoreApi = FirestoreAPIManager.shared
    
    let profileItems = ["My Orders", "Returns", "Invite Friends", "Payments", "Delete Account", "Help", "About", "Logout"]
    let profileItemsIcons = ["tag", "return", "person.fill.badge.plus", "dollarsign", "person", "questionmark.circle", "info","rectangle.portrait.and.arrow.forward"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [
            UIColor(red: 100/255.0, green: 184/255.0, blue: 225/255.0, alpha: 0.5).cgColor,
            UIColor(red: 200/255.0, green: 152/255.0, blue: 240/255.0, alpha: 0.5).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        self.view.layer.insertSublayer(gradient, at: 0)
        
        firestoreApi.returnCurrentUserName { userName in
            DispatchQueue.main.async {
                // Update UI on the main thread
                self.profileName.text = userName
            }
        }
        
        firestoreApi.returnCurrentUserProfileImageUrl { imageUrl in
            if let imageUrl = imageUrl {
                self.downloadImage(from: imageUrl) { image in
                    if let image = image {
                        self.profileImage.image = image
                    } else {
                        self.profileImage.image = UIImage(systemName: "person.fill")
                        // Handle error or placeholder image
                    }
                }
            } else {
                self.profileImage.image = UIImage(systemName: "person.fill")
                // Handle error or placeholder image
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
    }
    
    
    // Handle the tap on the image view
        @objc func imageViewTapped() {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            present(vc, animated: true)
        }
        
        // MARK: - UIImagePickerControllerDelegate
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage.image = image
            uploadImageToFirestore(image: image)
        }
        
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
        
        // Upload the image to Firestore
        func uploadImageToFirestore(image: UIImage) {
            // Convert the image to Data format if needed
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("Failed to convert image to Data format")
                return
            }
            
            // Upload imageData to Firestore here using FirestoreAPIManager.shared method
            // For example:
            firestoreApi.uploadImage(imageData: imageData) { result in
                switch result {
                case .success(let imageUrl):
                    print("Image uploaded successfully. Image URL: \(imageUrl)")
                    // Optionally, update the image view with the uploaded image
                    self.profileImage.image = image
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
            
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
//        profileImage.image = UIImage(systemName: "person.fill")
        
        profileView.layer.shadowColor = UIColor.darkGray.cgColor
        profileView.layer.shadowOpacity = 0.5
        profileView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileView.layer.shadowRadius = 5
        profileView.layer.cornerRadius = 15
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
        task.resume()
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
            tableView.deselectRow(at: indexPath, animated: true)

            let selectedItem = profileItems[indexPath.row]
            if selectedItem == "Logout" {
                do {
                    try Auth.auth().signOut()
                    showAlert(title: "Logged Out", message: "You have been logged out successfully.", completionHandler: {
                        // Navigate to the sign-in page after tapping "OK"
                        self.navigateToSignInPage()
                    })
                }
                catch {
        
                }
            } else if selectedItem == "Delete Account" {
                deleteAccount()
            } else {
                // Handle other cell selections if needed
        }
    }
    
    func showAlert(title: String, message: String, completionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func navigateToSignInPage() {
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        
        // Instantiate the login view controller
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? UIViewController {
            // Present the login view controller modally with full screen
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }

    func deleteAccount() {
        let confirmationAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Get the current user
            guard let currentUser = Auth.auth().currentUser else {
                print("No user signed in")
                return
            }
            
            // Delete the user account
            currentUser.delete { error in
                if let error = error {
                    print("Error deleting user account: \(error.localizedDescription)")
                    // Show an alert or handle the error accordingly
                } else {
                    print("User account deleted successfully")
                    self.showAlert(title: "Account Deleted", message: "Your account has been deleted successfully.", completionHandler: {
                        // Navigate to the sign-in page after tapping "OK"
                        self.navigateToSignInPage()
                    })
                }
            }
        }
        confirmationAlert.addAction(deleteAction)
        
        present(confirmationAlert, animated: true, completion: nil)
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
