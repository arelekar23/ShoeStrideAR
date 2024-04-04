//  Copyright Snap Inc. All rights reserved.
//  CameraKit

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CameraKitExtension)
/// Parent protocol of all CameraKit extensions. Conform to a specific type of extension, do not conform to this
/// protocol directly.
@protocol SCCameraKitExtension <NSObject>
@end

NS_SWIFT_NAME(CameraKitExtensible)
/// Exposes hooks to register extensions with CameraKit
@protocol SCCameraKitExtensible <NSObject>

/// Registers an extension with CameraKit.
/// @param extension the extension to register.
- (void)registerExtension:(id<SCCameraKitExtension>)extension;

@end

NS_ASSUME_NONNULL_END
