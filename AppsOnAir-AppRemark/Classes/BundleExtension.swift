import Foundation

/// helps to fetch the information from Bundle
extension Bundle {
    
//  help to get appName from project's info.plist
    var appName : String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
    var photoPermission : Bool? {
        return (infoDictionary?["NSPhotoLibraryUsageDescription"] as? String) != nil
    }
}
