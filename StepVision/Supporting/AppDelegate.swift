import UIKit
import SCSDKCameraKit
import SCSDKCameraKitReferenceUI
import SCSDKCreativeKit
#if CAMERAKIT_PUSHTODEVICE
    import SCSDKLoginKit
#endif
import Firebase
// Reenable if using SwiftUI reference UI
//import SCSDKCameraKitReferenceSwiftUI
//import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SnapchatDelegate {

    var window: UIWindow?
    
    private enum Constants {
        static let partnerGroupId = "b6f8aaeb-05f4-4c87-9973-a2fdd343258b"
    }
    fileprivate var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown

    let snapAPI = SCSDKSnapAPI()
    
    lazy var cameraController = {
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
        snapAPI.startSending(content) { error in
            DispatchQueue.main.async {
                viewController.view.isUserInteractionEnabled = true
            }
            if let error = error {
                print("Failed to send content to Snapchat with error: \(error.localizedDescription)")
                return
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
//        do {
//            try Auth.auth().signOut()
//        }
//        catch {
//            
//        }
        if let _ = Auth.auth().currentUser {
            // User is logged in
            navigateToHomeScreen()
        }
        
//        window = UIWindow(frame: UIScreen.main.bounds)
//        if let previousGroupIDs = debugStore?.groupIDs {
//            cameraController.groupIDs = previousGroupIDs
//        } else {
//            cameraController.groupIDs = [SCCameraKitLensRepositoryBundledGroup, Constants.partnerGroupId]
//        }
//        cameraController.snapchatDelegate = self
//        let cameraViewController = CustomizedCameraViewController(cameraController: cameraController, debugStore: debugStore)
//        cameraViewController.appOrientationDelegate = self
//        window?.rootViewController = cameraViewController
//        window?.makeKeyAndVisible()
        return true
    }
    
    func navigateToHomeScreen() {
        // Instantiate the storyboard containing the tab bar controller
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        // Instantiate the tab bar controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! UIViewController
        
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

}


extension AppDelegate: AppOrientationDelegate {

    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        supportedOrientations = orientation
    }

    func unlockOrientation() {
        supportedOrientations = .allButUpsideDown
    }

}
