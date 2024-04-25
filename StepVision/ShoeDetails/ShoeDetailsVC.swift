//
//  ShoeDetailsVC.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/21/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import UIKit
import SCSDKCameraKit
import SCSDKCameraKitReferenceUI
import SCSDKCreativeKit
#if CAMERAKIT_PUSHTODEVICE
    import SCSDKLoginKit
#endif

class ShoeDetailsVC: UIViewController, SnapchatDelegate, AppOrientationDelegate {

    private enum Constants {
        static let partnerGroupId = "b6f8aaeb-05f4-4c87-9973-a2fdd343258b"
    }

    var window: UIWindow?
    fileprivate var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown

    let snapAPI = SCSDKSnapAPI()
    lazy var cameraController: CustomizedCameraController = {
        if let token = debugStore?.apiToken {
            return CustomizedCameraController(sessionConfig: SessionConfig(apiToken: token))
        } else {
            return CustomizedCameraController()
        }
    }()

    private let debugStore: (any DebugStoreProtocol)? = {
        if #available(iOS 13, *) {
            return DebugStore(defaultGroupIDs: [SCCameraKitLensRepositoryBundledGroup, Constants.partnerGroupId])
        } else {
            return nil
        }
    }()

    func cameraKitViewController(_ viewController: UIViewController, openSnapchat screen: SnapchatScreen) {
        switch screen {
        case .profile, .lens(_):
            // not supported yet in creative kit (1.4.2), should be added in next version
            break
        case .photo(let image):
            let photo = SCSDKSnapPhoto(image: image)
            let content = SCSDKPhotoSnapContent(snapPhoto: photo)
            sendSnapContent(content, viewController: viewController)
        case .video(let url):
            let video = SCSDKSnapVideo(videoUrl: url)
            let content = SCSDKVideoSnapContent(snapVideo: video)
            sendSnapContent(content, viewController: viewController)
        }
    }

    private func sendSnapContent(_ content: SCSDKSnapContent, viewController: UIViewController) {
        viewController.view.isUserInteractionEnabled = false
        
        DispatchQueue.global().async { [weak self] in
            // Perform AVCaptureSession operations on a background thread
            self?.snapAPI.startSending(content) { error in
                DispatchQueue.main.async {
                    viewController.view.isUserInteractionEnabled = true
                }
                if let error = error {
                    print("Failed to send content to Snapchat with error: \(error.localizedDescription)")
                    return
                }
            }
        }
    }


    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedOrientations
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        debugStore?.processDeepLink(url)
#if CAMERAKIT_PUSHTODEVICE
        return SCSDKLoginClient.application(app, open: url, options: options)
#endif
    }
    
    var cameraViewController: CameraViewController?
    
    var shoe: Shoes?
    var imageName: String?

  
    @IBOutlet var detailsView: UIView!
    @IBOutlet var brand: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var shoeDescription: UILabel!
    @IBOutlet var shoeBg: UIView!
    @IBOutlet var shoeImage: UIImageView!
    @IBOutlet var arButton: UIButton!
    @IBOutlet var buttonsView: UIView!
    //    @IBOutlet var addToCart: UIButton!
    
    @IBOutlet var navBar: UINavigationItem!
    
    override func viewDidLoad() {
//        self.view.bounds.origin.y = +92
        super.viewDidLoad()
        
        detailsView.layer.shadowColor = UIColor.gray.cgColor
        detailsView.layer.shadowOpacity = 0.5
        detailsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailsView.layer.shadowRadius = 4
        detailsView.layer.cornerRadius = 10
        
        buttonsView.layer.shadowColor = UIColor.gray.cgColor
        buttonsView.layer.shadowOpacity = 0.5
        buttonsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        buttonsView.layer.shadowRadius = 4
        buttonsView.layer.cornerRadius = 25
        
        
        if let previousGroupIDs = debugStore?.groupIDs {
            cameraController.groupIDs = previousGroupIDs
        } else {
            cameraController.groupIDs = [SCCameraKitLensRepositoryBundledGroup, Constants.partnerGroupId]
        }
        cameraController.snapchatDelegate = self
        cameraViewController = CustomizedCameraViewController(cameraController: cameraController, debugStore: debugStore)
        cameraViewController?.appOrientationDelegate = self
//        tempView.bringSubviewToFront(addToCart)
                
        setup()
        
        createBg()

    }
 
    @IBAction func openCamera(_ sender: UIButton) {
        DispatchQueue.global().async { [weak self] in
                // Execute AVCaptureSession operations on a background thread
                self?.startCaptureSession()
            }
    }
    func createBg() {
        let curveLayer = CAShapeLayer()
        shoeBg.frame = shoeBg.bounds

        // Create a bezier path for the curve
        let curvePath = UIBezierPath()
        curvePath.move(to: CGPoint(x: 0, y: 0))
        curvePath.addQuadCurve(to: CGPoint(x: shoeBg.bounds.width, y: shoeBg.bounds.height), controlPoint: CGPoint(x: 0, y: shoeBg.bounds.height))


        // Create a rectangle path for the remaining area
        curvePath.addLine(to: CGPoint(x: shoeBg.bounds.width, y: 0)) // Straight line to top-right corner
        curvePath.addLine(to: CGPoint(x: 0, y: 0))
        curvePath.close()

        curveLayer.path = curvePath.cgPath
        shoeBg.layer.mask = curveLayer
        

        // Set the frame of the image view to be smaller than shoeBg's frame
        let smallerSize = CGSize(width: shoeBg.bounds.width * 0.8, height: shoeBg.bounds.height * 0.8)
        let origin = CGPoint(x: (shoeBg.bounds.width - smallerSize.width) / 2, y: (shoeBg.bounds.height - smallerSize.height) / 2 + 60)
        shoeImage.frame = CGRect(origin: origin, size: smallerSize)
        // Rotate the image by 45 degrees clockwise and mirror horizontally
        shoeImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3.7 / 4) // Rotate by 45 degrees
        shoeImage.transform = shoeImage.transform.scaledBy(x: 1, y: -1)
        // Add the image view as a sibling view to shoeBg
        shoeBg.superview?.addSubview(shoeImage)
    }
    func createDiagonalCurve(view: UIView) {
        let curvePath = UIBezierPath()
        curvePath.move(to: CGPoint(x: 0, y: 0)) // Start from top-left corner
        curvePath.addQuadCurve(to: CGPoint(x: view.bounds.width, y: view.bounds.height), controlPoint: CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)) // Draw a curve to the bottom-right corner

        // Create a shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        
        // Apply the shape layer as a mask to the view's layer
        view.layer.mask = shapeLayer
    }
    
    func setup() {
        name.text = shoe?.shoeName
        if let retailPrice = shoe?.retailPrice {
            price.text = "$ " + String(retailPrice)
        } else {
            price.text = "Price not available"
        }
        brand.text = shoe?.brand
        shoeImage.image = UIImage(named: imageName!)
        shoeDescription.text = shoe?.description
    }
    
    private func startCaptureSession() {
        // Ensure cameraController is properly initialized
//        let cameraViewController = CustomizedCameraViewController(cameraController: cameraController, debugStore: debugStore)
//        cameraViewController.appOrientationDelegate = self
        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(self.cameraViewController!, animated: true)
            self.present(self.cameraViewController!, animated: true, completion: nil)
        }
    }
    
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        supportedOrientations = orientation
    }

    func unlockOrientation() {
        supportedOrientations = .allButUpsideDown
    }
}

