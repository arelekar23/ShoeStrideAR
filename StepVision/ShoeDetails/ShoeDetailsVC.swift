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

    let firestoreApi = FirestoreAPIManager.shared
    var partnersGroupId: String?
    private enum Constants {
        static var partnerGroupId = "3c0211a3-557d-462c-80cc-68c48e77b1ab"
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

    private lazy var debugStore: (any DebugStoreProtocol)? = {
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
    
    @IBOutlet var detailsView: UIView!
    @IBOutlet var brand: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var shoeDescription: UILabel!
    @IBOutlet var shoeBg: UIView!
    @IBOutlet var shoeImage: UIImageView!
    @IBOutlet var arButton: UIButton!
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var size1: UIButton!
    @IBOutlet var size2: UIButton!
    @IBOutlet var size3: UIButton!
    @IBOutlet var size4: UIButton!
    @IBOutlet var size5: UIButton!
    @IBOutlet var size6: UIButton!
    @IBAction func size1(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "38.square.fill")
        if isSelected {
            size1.setImage(UIImage(systemName: "38.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size1.setImage(UIImage(systemName: "38.square.fill"), for: .normal)
        }
    }
    @IBAction func size2(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "39.square.fill")
        if isSelected {
            size2.setImage(UIImage(systemName: "39.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size2.setImage(UIImage(systemName: "39.square.fill"), for: .normal)
        }
    }
    @IBAction func size3(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "40.square.fill")
        if isSelected {
            size3.setImage(UIImage(systemName: "40.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size3.setImage(UIImage(systemName: "40.square.fill"), for: .normal)
        }
    }
    @IBAction func size4(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "41.square.fill")
        if isSelected {
            size4.setImage(UIImage(systemName: "41.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size4.setImage(UIImage(systemName: "41.square.fill"), for: .normal)
        }
    }
    @IBAction func size5(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "42.square.fill")
        if isSelected {
            size5.setImage(UIImage(systemName: "42.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size5.setImage(UIImage(systemName: "42.square.fill"), for: .normal)
        }
    }
    @IBAction func size6(_ sender: UIButton) {
        let isSelected = size1.currentImage == UIImage(systemName: "43.square.fill")
        if isSelected {
            size6.setImage(UIImage(systemName: "43.square"), for: .normal)
        }
        else {
            deselectAllSizes()
            size6.setImage(UIImage(systemName: "43.square.fill"), for: .normal)
        }
    }
    
    func deselectAllSizes() {
        size1.setImage(UIImage(systemName: "38.square"), for: .normal)
        size2.setImage(UIImage(systemName: "39.square"), for: .normal)
        size3.setImage(UIImage(systemName: "40.square"), for: .normal)
        size4.setImage(UIImage(systemName: "41.square"), for: .normal)
        size5.setImage(UIImage(systemName: "42.square"), for: .normal)
        size6.setImage(UIImage(systemName: "43.square"), for: .normal)
    }
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if let shoe = shoe {
            let isLiked = likeButton.currentImage == UIImage(systemName: "heart.fill")
            if isLiked {
                // If already liked, decrement favorites count
                firestoreApi.decrementFavoritesCount(for: shoe) { success in
                    if success {
                        print("Favorites count decremented successfully.")
                    } else {
                        print("Failed to decrement favorites count.")
                    }
                }
                firestoreApi.updateFavoriteShoes(shoeName: shoe.shoeName, isFavorite: false) { success in
                    if success {
                        print("Favorite shoes updated successfully.")
                    } else {
                        print("Failed to update favorite shoes.")
                        // Handle error
                    }
                }
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            } else {
                // If not liked, increment favorites count
                firestoreApi.incrementFavoritesCount(for: shoe) { success in
                    if success {
                        print("Favorites count incremented successfully.")
                    } else {
                        print("Failed to increment favorites count.")
                    }
                }
                firestoreApi.updateFavoriteShoes(shoeName: shoe.shoeName, isFavorite: true) { success in
                    if success {
                        print("Favorite shoes updated successfully.")
                    } else {
                        print("Failed to update favorite shoes.")
                        // Handle error
                    }
                }
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
    }



    //    @IBOutlet var addToCart: UIButton!
    
    @IBOutlet var navBar: UINavigationItem!
    
    override func viewDidLoad() {
//        self.view.bounds.origin.y = +92
        super.viewDidLoad()
//        Constants.partnerGroupId = partnersGroupId!
        firestoreApi.isShoeInFavorites(shoeName: shoe!.shoeName) { isInFavorites in
            if isInFavorites {
                self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                print("The shoe is in favorites.")
            } else {
                self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                print("The shoe is not in favorites.")
            }
        }

//
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
            cameraController.groupIDs = [Constants.partnerGroupId]
        } else {
            cameraController.groupIDs = [SCCameraKitLensRepositoryBundledGroup, Constants.partnerGroupId]
        }
//        cameraController.groupIDs = [Constants.partnerGroupId]
        cameraController.snapchatDelegate = self
        cameraViewController = CustomizedCameraViewController(cameraController: cameraController, debugStore: debugStore)
        cameraViewController?.appOrientationDelegate = self
//        tempView.bringSubviewToFront(addToCart)
                
        setup()
        
        createBg()

    }
 
    @IBAction func addToCart(_ sender: UIButton) {
        firestoreApi.addToCart(shoes: shoe!, quantity: 1) { result, success in
            switch result {
            case .success:
                // Show alert on successful addition
                let alert = UIAlertController(title: "Success", message: "Shoes added to cart.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .failure(let error):
                // Handle error, if any
                print("Error: \(error.localizedDescription)")
            }
        }
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
        shoeImage.image = UIImage(named: shoe!.image)
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

