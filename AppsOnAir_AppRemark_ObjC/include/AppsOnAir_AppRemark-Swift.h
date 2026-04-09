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

/// Programmatically open the remark screen.
- (void)addRemark;

/// Attach extra key/value pairs included with every remark submission.
/// @param extraPayload  Dictionary of additional metadata.
- (void)setAdditionalMetaDataWithExtraPayload:(NSDictionary *)extraPayload;

@end

NS_ASSUME_NONNULL_END
