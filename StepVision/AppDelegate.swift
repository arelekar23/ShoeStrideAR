import UIKit
import SCSDKCameraKit
import SCSDKCameraKitReferenceUI
import SCSDKCreativeKit
#if CAMERAKIT_PUSHTODEVICE
    import SCSDKLoginKit
#endif
// Reenable if using SwiftUI reference UI
//import SCSDKCameraKitReferenceSwiftUI
//import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
//, SnapchatDelegate
{

    var window: UIWindow?
//    
//    private enum Constants {
//        static let partnerGroupId = "b6f8aaeb-05f4-4c87-9973-a2fdd343258b"
//    }
//    fileprivate var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown
//
//    let snapAPI = SCSDKSnapAPI()
//    
//    lazy var cameraController = {
//        if let token = debugStore?.apiToken {
//            return CustomizedCameraController(sessionConfig: SessionConfig(apiToken: token))
//        } else {
//            return CustomizedCameraController()
//        }
//    }()
//    private let debugStore: (any DebugStoreProtocol)? = {
//        if #available(iOS 13, *) {
//            return DebugStore(defaultGroupIDs: [SCCameraKitLensRepositoryBundledGroup, Constants.partnerGroupId])
//        } else {
//            return nil
//        }
//    }()
//    
//    func cameraKitViewController(_ viewController: UIViewController, openSnapchat screen: SnapchatScreen) {
//        switch screen {
//        case .profile, .lens(_):
//            // not supported yet in creative kit (1.4.2), should be added in next version
//            break
//        case .photo(let image):
//            let photo = SCSDKSnapPhoto(image: image)
//            let content = SCSDKPhotoSnapContent(snapPhoto: photo)
//            sendSnapContent(content, viewController: viewController)
//        case .video(let url):
//            let video = SCSDKSnapVideo(videoUrl: url)
//            let content = SCSDKVideoSnapContent(snapVideo: video)
//            sendSnapContent(content, viewController: viewController)
//        }
//    }
//
//    private func sendSnapContent(_ content: SCSDKSnapContent, viewController: UIViewController) {
//        viewController.view.isUserInteractionEnabled = false
//        snapAPI.startSending(content) { error in
//            DispatchQueue.main.async {
//                viewController.view.isUserInteractionEnabled = true
//            }
//            if let error = error {
//                print("Failed to send content to Snapchat with error: \(error.localizedDescription)")
//                return
//            }
//        }
//    }
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return supportedOrientations
//    }
//    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
//    {
//        debugStore?.processDeepLink(url)
//#if CAMERAKIT_PUSHTODEVICE
//        return SCSDKLoginClient.application(app, open: url, options: options)
//#endif
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
}


//extension AppDelegate: AppOrientationDelegate {
//
//    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
//        supportedOrientations = orientation
//    }
//
//    func unlockOrientation() {
//        supportedOrientations = .allButUpsideDown
//    }
//
//}
