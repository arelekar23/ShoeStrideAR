//  Copyright Snap Inc. All rights reserved.
//  CameraKit

#import <SCSDKCameraKitBaseExtension/SCCameraKitBaseExtension.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCCameraKitProtocol;
@protocol SCCameraKitAccessTokenProvider;
@protocol SCCameraKitLens;
@protocol SCCameraKitOutput;

NS_SWIFT_NAME(PushToDeviceService)
@protocol SCCameraKitPushToDeviceService <NSObject>
@end

FOUNDATION_EXPORT NSString *const SCCameraKitPushToDeviceGroupID;
FOUNDATION_EXPORT NSString *const SCCameraKitPushToDeviceErrorDomain;

NS_SWIFT_NAME(PushToDeviceProtocol)
/// Protocol that describes an object that pairs a device and the lens studio backend
@protocol SCCameraKitPushToDeviceProtocol <SCCameraKitExtension>

/// Begin the pairing process which may initiate a login flow if the developer is not already logged in.
- (void)initiatePairing API_AVAILABLE(ios(12));

/// The push to device service to handle auth, scanning, etc.
@property (nonatomic, strong, readonly) id<SCCameraKitPushToDeviceService> service;

@end

NS_SWIFT_NAME(PushToDeviceDelegate)
@protocol SCCameraKitPushToDeviceDelegate <NSObject>

/// Called when the push to device object has successfully obtained an Authentication Token
/// @param pushToDevice The instance of the object that called this method
- (void)pushToDeviceDidAcquireAuthToken:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice
    NS_SWIFT_NAME(pushToDeviceDidAcquireAuthToken(_:));

/// Called when the push to device object fails to obtain an Authentication Token with an error
/// @param pushToDevice The instance of the object that called this method
/// @param error The error that occurred when we attempted to acquire an authorization token
- (void)pushToDevice:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice
    failedToAcquireAuthTokenWithError:(NSError *)error NS_SWIFT_NAME(pushToDevice(_:failedToAcquireAuthToken:));

/// Called when the push to device object has scanned a Snapcode and has a UUID
/// @param pushToDevice The instance of the object that called this method
- (void)pushToDeviceDidScanSnapcode:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice
    NS_SWIFT_NAME(pushToDeviceDidScanSnapcode(_:));

/// Called when the push to device fails to scan a snapcode with an error
/// @param pushToDevice The instance of the object that called this method
/// @param error The error that occurred when we attempted to scan the snapcode
- (void)pushToDevice:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice
    failedToScanSnapcodeWithError:(NSError *)error NS_SWIFT_NAME(pushToDevice(_:failedToScanSnapcodeWithError:));

/// Called when the device pairing has succeeded
/// @param pushToDevice The instance of the object that called this method
- (void)pushToDeviceComplete:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice NS_SWIFT_NAME(pushToDeviceComplete(_:));

/// Notify the delegate that a push attempt occurred but there was an error and no lens was received
/// @param pushToDevice The instance of the object that called this method
/// @param error The error that occurred when an lens was pushed to us or when we registered to listen for pushes
- (void)pushToDevice:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice
    didReceiveLensPushError:(NSError *)error NS_SWIFT_NAME(pushToDevice(_:didReceiveLensPushError:));

/// Notify the delegate that a lens has been receieved.
/// @param pushToDevice The instance of the object that called this method
/// @param lens The lens received
- (void)pushToDevice:(id<SCCameraKitPushToDeviceProtocol>)pushToDevice receivedLens:(id<SCCameraKitLens>)lens;

@end

/// A SCCameraKitDevice is an object which manages the coordination between the client application, LensStudio on
/// a Lens developers computer, and the Snapchat backend which has more context of what a Snapchat user is. The lens
/// developer will use an instance of this class to pair their device running CameraKit to their Snapchat account, and
/// in turn map that acount to the LensStudio lens on which they are working.
NS_SWIFT_NAME(PushToDevice)
@interface SCCameraKitPushToDevice : NSObject <SCCameraKitPushToDeviceProtocol>

@property (nonatomic, weak, nullable) id<SCCameraKitPushToDeviceDelegate> delegate;

/// Initializes an instance of a SCCameraKitDevicePairing to handle all LensStudio to CameraKit push to device tasks
/// @param cameraKit The SCCameraKitSession object which will be used as a source for Snapcode scanning
/// @param tokenProvider An object which provides an authorization token. The most likely provider will be LoginKit
- (instancetype)initWithCameraKitSession:(id<SCCameraKitProtocol>)session
                           tokenProvider:(id<SCCameraKitAccessTokenProvider>)tokenProvider API_AVAILABLE(ios(12));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
