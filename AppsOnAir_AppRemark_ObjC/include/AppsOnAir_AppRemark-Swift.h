#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// ObjC interface for AppsOnAir AppRemark SDK.
///
/// ─── CocoaPods (Objective-C) ─────────────────────────────────────────────────
///   #import "AppsOnAir_AppRemark-Swift.h"
///
/// ─── SPM (Objective-C) ───────────────────────────────────────────────────────
///   Add "AppsOnAir-AppRemark" product to your target, then:
///   #import "AppsOnAir_AppRemark-Swift.h"
///

/// How hard the device must be shaken to open the remark screen.
typedef NS_ENUM(NSInteger, ShakeSensitivity) {
    ShakeSensitivityVeryLow = 0,
    ShakeSensitivityLow = 1,
    ShakeSensitivityMedium = 2,
    ShakeSensitivityHigh = 3,
    ShakeSensitivityVeryHigh = 4,
};

@interface AppRemarkService : NSObject

/// Shared singleton instance.
+ (instancetype)shared;

/// Initialise the AppRemark SDK.
/// @param shakeGestureEnable  Pass YES to open the remark screen on device shake.
/// @param options             Customisation dictionary (keys are case-insensitive).
/// @param onRemarkResponse    Called on every remark submission with the response payload.
- (void)initializeWithShakeGestureEnable:(BOOL)shakeGestureEnable
                                 options:(NSDictionary *)options
                        onRemarkResponse:(void (^)(NSDictionary *remarkInfo))onRemarkResponse;

/// Initialise the AppRemark SDK with a custom shake sensitivity.
/// Without it (method above) the system shake gesture is used.
/// @param shakeGestureEnable  Pass YES to open the remark screen on device shake.
/// @param options             Customisation dictionary (keys are case-insensitive).
/// @param shakeSensitivity    How hard the device must be shaken.
/// @param onRemarkResponse    Called on every remark submission with the response payload.
- (void)initializeWithShakeGestureEnable:(BOOL)shakeGestureEnable
                                 options:(NSDictionary *)options
                        shakeSensitivity:(ShakeSensitivity)shakeSensitivity
                        onRemarkResponse:(void (^)(NSDictionary *remarkInfo))onRemarkResponse;

/// Programmatically open the remark screen.
- (void)addRemark;

/// Attach extra key/value pairs included with every remark submission.
/// @param extraPayload  Dictionary of additional metadata.
- (void)setAdditionalMetaDataWithExtraPayload:(NSDictionary *)extraPayload;

/// Change how hard the device must be shaken at runtime.
/// Switches from the system shake gesture to the given sensitivity.
/// @param shakeSensitivity  New sensitivity, applied to the next shake.
- (void)setShakeSensitivity:(ShakeSensitivity)shakeSensitivity;

@end

NS_ASSUME_NONNULL_END
