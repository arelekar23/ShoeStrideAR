//
//  SignupVC.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/5/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {

    let auth = AuthService.shared
    @IBOutlet var name: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.cornerRadius = 50
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupBtn(_ sender: UIButton) {
        let userRequest = RegisterUserRequest(name: name.text ?? "",
                                                       email: emailAddress.text ?? "",
                                                       password: password.text ?? "")
        auth.registerUser(with: userRequest, completion: { success, error in
            if success {
                self.performSegue(withIdentifier: "ToLoginVC", sender: Any?.self)
                print("Registeration successful")
            } 
            else {
                // Registration failed
                if let error = error {
                    AlertManager.showRegistrationErrorAlert(on: self, with: error)
                    print("Registration failed with error: \(error.localizedDescription)")
                } else {
                    AlertManager.showRegistrationErrorAlert(on: self)
                    print("Registration failed")
                }
            }})
    }
    
    @IBOutlet var logo: UIImageView!

}
