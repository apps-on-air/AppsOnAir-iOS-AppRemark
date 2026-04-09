// ObjC bridge for AppsOnAir_AppRemark Swift module.
// Uses runtime class lookup to avoid a compile-time ObjC/Swift name conflict.
// The public interface lives in include/AppsOnAir_AppRemark-Swift.h for consumers.
//
// Swift registers @objc framework classes with their module-qualified name
// (e.g. "AppsOnAir_AppRemark.AppRemarkService"), so this ObjC class
// ("AppRemarkService") and the Swift class coexist without a symbol collision.
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Redeclare the public interface inline so this file needs no header search path.
@interface AppRemarkService : NSObject
+ (instancetype)shared;
- (void)initializeWithShakeGestureEnable:(BOOL)shakeGestureEnable
                                 options:(NSDictionary *)options
                        onRemarkResponse:(void (^)(NSDictionary *remarkInfo))onRemarkResponse;
- (void)addRemark;
- (void)setAdditionalMetaDataWithExtraPayload:(NSDictionary *)extraPayload;
@end

NS_ASSUME_NONNULL_END

@interface AppRemarkService ()
// Stored as opaque `id` to avoid importing the Swift module and causing a
// redefinition conflict with the Swift-exported `AppRemarkService`.
@property(nonatomic, strong) id swiftService;
@end

@implementation AppRemarkService

+ (instancetype)shared {
    static AppRemarkService *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Resolve the Swift class at runtime to avoid a compile-time name conflict.
        Class swiftClass = NSClassFromString(@"AppsOnAir_AppRemark.AppRemarkService");
        NSAssert(swiftClass != nil,
                 @"AppsOnAir_AppRemark framework must be linked. "
                 @"Make sure AppsOnAir-AppRemark is added as a dependency.");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        _swiftService = [swiftClass performSelector:NSSelectorFromString(@"shared")];
#pragma clang diagnostic pop
    }
    return self;
}

- (void)initializeWithShakeGestureEnable:(BOOL)shakeGestureEnable
                                 options:(NSDictionary *)options
                        onRemarkResponse:(void (^)(NSDictionary *))onRemarkResponse {
    SEL sel = NSSelectorFromString(@"initializeWithShakeGestureEnable:options:onRemarkResponse:");
    NSMethodSignature *sig = [self.swiftService methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:sel];
    [inv setTarget:self.swiftService];
    [inv setArgument:&shakeGestureEnable atIndex:2];
    [inv setArgument:&options atIndex:3];
    id block = ^(NSDictionary *response) {
        if (onRemarkResponse) onRemarkResponse(response);
    };
    [inv setArgument:&block atIndex:4];
    [inv invoke];
}

- (void)addRemark {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.swiftService performSelector:NSSelectorFromString(@"addRemark")];
#pragma clang diagnostic pop
}

- (void)setAdditionalMetaDataWithExtraPayload:(NSDictionary *)extraPayload {
    SEL sel = NSSelectorFromString(@"setAdditionalMetaDataWithExtraPayload:");
    NSMethodSignature *sig = [self.swiftService methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:sel];
    [inv setTarget:self.swiftService];
    [inv setArgument:&extraPayload atIndex:2];
    [inv invoke];
}

@end
