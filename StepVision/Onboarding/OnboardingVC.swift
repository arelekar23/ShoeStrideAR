//
//  WelcomeVC.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//

//import UIKit
//import SwiftUI
//import FirebaseAuth
//
//class OnboardingVC: UIViewController {
//
//    @IBOutlet var nextBtn: UIButton!
//    @IBOutlet var splineView: UIView!
//    let contentView = UIHostingController(rootView: ContentView())
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addChild(contentView)
//        splineView.addSubview(contentView.view)
//        setupConstraints()
//    }
//    
//    
//    fileprivate func setupConstraints() {
//        contentView.view?.translatesAutoresizingMaskIntoConstraints = false
//        contentView.view.topAnchor.constraint(equalTo: splineView.topAnchor).isActive = true
//        contentView.view.bottomAnchor.constraint(equalTo: splineView.bottomAnchor).isActive = true
//        contentView.view.leftAnchor.constraint(equalTo: splineView.leftAnchor).isActive = true
//        contentView.view.rightAnchor.constraint(equalTo: splineView.rightAnchor).isActive = true
//        
//    }
//    
//    @IBAction func nextBtnTapped(_ sender: UIButton) {
//    }
//}

import UIKit
import SwiftUI
import FirebaseAuth

class OnboardingVC: UIViewController {

    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var splineView: UIView!
    var loadingView: UIView?
    let contentView = UIHostingController(rootView: ContentView())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplineView()
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
//        64, 132, 238
//        56, 190, 212
        let buttonGradient = CAGradientLayer()
        buttonGradient.frame = nextBtn.bounds
        buttonGradient.colors = [
            UIColor(red: 84/255.0, green: 184/255.0, blue: 225/255.0, alpha: 0.5).cgColor,
            UIColor(red: 73/255.0, green: 152/255.0, blue: 240/255.0, alpha: 0.5).cgColor
        ]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0.5)
        buttonGradient.endPoint = CGPoint(x: 1, y: 0.5)
        nextBtn.layer.cornerRadius = 12
        nextBtn.layer.insertSublayer(buttonGradient, at: 0)
        nextBtn.layer.masksToBounds = true

    }

    fileprivate func setupSplineView() {
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

