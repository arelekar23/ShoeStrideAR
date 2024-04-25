//
//  WelcomeVC.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth

class OnboardingVC: UIViewController {

    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var splineView: UIView!
    let contentView = UIHostingController(rootView: ContentView())
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(contentView)
        splineView.addSubview(contentView.view)
        setupConstraints()
    }
    
    
    fileprivate func setupConstraints() {
        contentView.view?.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: splineView.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: splineView.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: splineView.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: splineView.rightAnchor).isActive = true
        
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
    }
}


