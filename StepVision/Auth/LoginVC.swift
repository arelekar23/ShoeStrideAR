//
//  LoginVC.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/5/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    let auth = AuthService.shared
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.cornerRadius = 50
        
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        let userRequest = LoginUserRequest(email: emailAddress.text ?? "",
                                           password: password.text ?? "")
        auth.signIn(with: userRequest) { error in
                if let error = error {
                    // Registration failed
                    AlertManager.showSignInErrorAlert(on: self, with: error)
                    print("Sign-In failed with error: \(error.localizedDescription)")
                } else {
                    // Sign-in successful
                    self.navigateToHomeScreen()
//                    self.performSegue(withIdentifier: "ToHomeVC", sender: self)
                    print("Sign-in successful")
                }
            }
    }
    
    func navigateToHomeScreen() {
        // Instantiate the storyboard containing the tab bar controller
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        // Instantiate the tab bar controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC") 
        
        // Wrap the tab bar controller within a navigation controller
        let navigationController = UINavigationController(rootViewController: viewController)
        
//        // Assuming the home view controller is the first view controller in the tab bar controller's viewControllers array
//        if let homeViewController = tabBarController.viewControllers?.first as? HomeVC {
//            // Set the selected view controller of the tab bar controller to the home view controller
//            tabBarController.selectedViewController = homeViewController
//        }
        
        // Present the navigation controller
        navigationController.modalPresentationStyle = .fullScreen
        
        // Set the navigation controller as the root view controller
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = navigationController
        }
    }
    @IBAction func newUserTapped(_ sender: UIButton) {
    }
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
    }
}
