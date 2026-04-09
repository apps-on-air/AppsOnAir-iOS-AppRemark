import Foundation

/// helps to fetch the information from Bundle
extension Bundle {

    //  help to get appName from project's info.plist
    var appName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }

    var photoPermission: Bool? {
        return (infoDictionary?["NSPhotoLibraryUsageDescription"] as? String) != nil
    }

    /// Returns the resource bundle that contains storyboards, XIBs, and assets.
    ///
    /// - When built with **Swift Package Manager** `Bundle.module` is used,
    ///   which is the automatically-generated module bundle.
    /// - When built with **CocoaPods** the classic `.bundle` lookup is used.
    ///
    /// Usage (Swift & Objective-C):
    /// ```swift
    /// let bundle = Bundle.remarkBundle
    /// ```
    @objc static var remarkBundle: Bundle {
        #if SWIFT_PACKAGE
            return .module
        #else
            // CocoaPods embeds resources in a named .bundle alongside the framework.
            let frameworkBundle = Bundle(for: _AppRemarkBundleToken.self)
            let bundleURL = frameworkBundle.url(
                forResource: "AppsOnAir-AppRemark", withExtension: "bundle")
            return bundleURL.flatMap { Bundle(url: $0) } ?? frameworkBundle
        #endif
    }
}

/// Private token class used only for CocoaPods bundle resolution.
/// Must stay in the same module so `Bundle(for:)` resolves the correct bundle.
private class _AppRemarkBundleToken {}
