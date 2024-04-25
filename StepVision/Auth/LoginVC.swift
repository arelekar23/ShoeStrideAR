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
                    self.performSegue(withIdentifier: "ToHomeVC", sender: self)
                    print("Sign-in successful")
                }
            }
    }
    @IBAction func newUserTapped(_ sender: UIButton) {
    }
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
    }
}
