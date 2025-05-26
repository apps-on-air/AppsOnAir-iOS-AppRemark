import Foundation
import UIKit
import AVFoundation
import Photos
import Contacts
import EventKit
import CoreMotion
import WidgetKit
import CoreBluetooth
import LocalAuthentication
import Network
import CoreTelephony
import AdSupport
import AppsOnAir_Core

class AdditionalDeviceInfo {
    
    static private func fetchMicroPermission(_ status: AVAudioSession.RecordPermission) -> String {
        switch status {
        case .granted: return "authorized"
        case .denied: return "denied"
        case .undetermined: return "notDetermined"
        @unknown default: return "unknown"
        }
    }
    
    static private func fetchPhotoPermission(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "authorized"
        case .limited: return "limited"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        @unknown default: return "unknown"
        }
    }
    
    static private func fetchContactPermission(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .limited: return "limited"
        @unknown default: return "unknown"
        }
    }
    
    static private func fetchCalenderPermission(_ status: EKAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .fullAccess: return "fullAccess"
        case .writeOnly: return "writeOnly"
        @unknown default: return "unknown"
        }
    }
    
    static private func fetchLocationPermission() -> String{
        var status: CLAuthorizationStatus = .notDetermined
        if #available(iOS 14.0, *){
            status = CLLocationManager().authorizationStatus
        }else{
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedAlways:return "authorizedAlways"
        case .authorizedWhenInUse:return "authorizedWhenInUse"
        case .denied:return "denied"
        case .restricted:return "restricted"
        case .notDetermined:return "notDetermined"
        @unknown default:return  "unknown"
        }
    }
    
    static private func fetchCameraPermission(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        @unknown default: return "unknown"
        }
    }
    
    //MARK: fetch the motion permission status
    //fetch motion permission status
    static func fetchMotionPermission() -> String {
        let status = CMMotionActivityManager.authorizationStatus()
        switch status {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        @unknown default: return "unknown"
        }
    }
    
    //MARK: createPermission for handling permission
    static private func createPermission(infoPlistKey: String,
                                 isEnable: String,
                                         permissionValue: String? = nil) -> [String: String] {
        return [
            infoPlistKey : permissionValue != nil ? (permissionValue ?? "") : isEnable
        ]
    }
    
    // MARK: fetch the permissions Information
    /// fetch the permissions Information from info.plist
    static func permissionsInfo() -> [String:String] {
        let plist = Bundle.main.infoDictionary ?? [:]
        var permissions: [String:String] = [:]
      
        
        let usageKeys = plist.keys.filter { $0.contains("UsageDescription") || $0.contains("UIBackgroundModes") }
        for type in usageKeys {
            var lsPermissionsInfo: [String:String]
            
            switch true {
            case type.contains("Camera"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSCameraUsageDescription", isEnable: fetchCameraPermission(AVCaptureDevice.authorizationStatus(for: .video)))
                
            case type.contains("Microphone"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSMicrophoneUsageDescription",isEnable: fetchMicroPermission(AVAudioSession.sharedInstance().recordPermission))
                
                
            case type.contains("Photo"):
                let photoPermissionAddKey = plist["NSPhotoLibraryAddUsageDescription"] != nil
                lsPermissionsInfo = createPermission(infoPlistKey: photoPermissionAddKey ?  "NSPhotoLibraryAddUsageDescription" : "NSPhotoLibraryUsageDescription", isEnable: fetchPhotoPermission(PHPhotoLibrary.authorizationStatus()))
                
                
            case type.contains("Contacts"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSContactsUsageDescription", isEnable: fetchContactPermission(CNContactStore.authorizationStatus(for: .contacts)))
                
                
            case type.contains("Calendar"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSCalendarsUsageDescription", isEnable: fetchCalenderPermission(EKEventStore.authorizationStatus(for: .event)))
                
            case type.contains("Motion"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSMotionUsageDescription", isEnable: fetchMotionPermission())
                
                
            case type.contains("Reminder"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSRemindersUsageDescription", isEnable: fetchCalenderPermission(EKEventStore.authorizationStatus(for: .reminder)))
                
            case type.contains("Location"):
                lsPermissionsInfo = createPermission(infoPlistKey: "NSLocationWhenInUseUsageDescription",isEnable: fetchLocationPermission())
                
            case type.contains("UIBackgroundModes"):
                lsPermissionsInfo = createPermission(infoPlistKey: "UIBackgroundModes", isEnable: "authorized" , permissionValue: fetchBackgroundModes())
                
            case type.contains("Bluetooth"):
                if #available(iOS 13.1, *) {
                    lsPermissionsInfo = createPermission(infoPlistKey: "NSBluetoothAlwaysUsageDescription", isEnable: fetchBluetoothPermission())
                    
                } else {
                    continue // Skip for iOS below 13.1
                }
                
            default:
                lsPermissionsInfo = [:]
            }
            
            if !(lsPermissionsInfo.isEmpty) {
                permissions.merge(lsPermissionsInfo) { (_, new) in new }
            }
        }
        
        return permissions
    }
    
    //MARK: Fetch BiometryInfo info
    /// fetch BiometryInfo info
    static func fetchBiometryInfo() -> [String:Bool] {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let biometryType = context.biometryType
        var biometryInfo: [String: Bool] = [
            "isBiometricSupported": canEvaluate,
            "isFaceIDAvailable": biometryType == .faceID,
            "isTouchIDAvailable": biometryType == .touchID,
            "isFaceIDEnrolled": canEvaluate && biometryType == .faceID
        ]
        if #available(iOS 17.0, *) {
            biometryInfo["isOpticIDAvailable"] =  biometryType == .opticID;
        }
        return biometryInfo;
        
    }
    
    // MARK: fetch permission status of bluetooth
    /// fetch permission status of bluetooth
    @available(iOS 13.1, *)
    static func fetchBluetoothPermission() -> String {
        let status = CBCentralManager.authorization
        switch status {
        case .allowedAlways:return "authorized"
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .restricted: return "denied"
        @unknown default: return "unknown"
        }
    }
    
    // MARK: fetch font scaling
    ///fetch the text scaling information
    static func fetchBackgroundModes() -> String? {
        guard let info = Bundle.main.infoDictionary else {
            return nil
        }
        
        if let backgroundModes = info["UIBackgroundModes"] as? [String] {
            return formatPermissionsList(backgroundModes)
        } else {
            return nil // Key doesn't exist
        }
    }
    
    //convert [String: Bool]? into single string
    static private func formatPermissionsList(_ permissions: [String]?) -> String {
        guard let permissions = permissions else { return "" }
        return permissions.map { "\($0)" }.joined(separator: ", ")
    }

    
    // MARK: fetch font scaling
    ///fetch the text scaling information
    static func fetchFontScale() -> Float {
        var fontScale: Float = 1.0
        
#if !os(visionOS)
        let traitCollection = UIScreen.main.traitCollection
        let contentSizeCategory = traitCollection.preferredContentSizeCategory
        
        switch contentSizeCategory {
        case .extraSmall: fontScale = 0.82
        case .small: fontScale = 0.88
        case .medium: fontScale = 0.95
        case .large: fontScale = 1.0
        case .extraLarge: fontScale = 1.12
        case .extraExtraLarge: fontScale = 1.23
        case .extraExtraExtraLarge: fontScale = 1.35
        case .accessibilityMedium: fontScale = 1.64
        case .accessibilityLarge: fontScale = 1.95
        case .accessibilityExtraLarge: fontScale = 2.35
        case .accessibilityExtraExtraLarge: fontScale = 2.76
        case .accessibilityExtraExtraExtraLarge: fontScale = 3.12
        default: fontScale = 1.0
        }
#endif
        
        return fontScale
    }
    
    // MARK: fetch locale info
    static func fetchLocaleDetails() -> String {
        let locale = Locale.current

        let language: String
        let region: String

        if #available(iOS 16.0, *) {
            language = locale.language.languageCode?.identifier ?? "unknown"
            region = locale.region?.identifier ?? "unknown"
        } else {
            language = locale.languageCode ?? "unknown"
            region = locale.regionCode ?? "unknown"
        }

        return "\(language)_\(region)"
    }
    
    //MARK: fetch public IP
    static func fetchPublicIp(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.ipify.org") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            
            if let data = data, let ipAddress = String(data: data, encoding: .utf8) {
                completion(ipAddress)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }

    
    // MARK: fetch device uniqueIdentifier
    static func fetchDeviceIdentifier() -> String {
        
        let idfv = DeviceUID.uid()
        return idfv
    }
    
    static func fetchThemeMode() -> String {
        var themeMode: String = "Unspecified"

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let style = window.traitCollection.userInterfaceStyle
            switch style {
            case .dark:
                themeMode = "dark"
            case .light:
                themeMode = "light"
            case .unspecified:
                break
            @unknown default:
                break
            }
        }

        return themeMode
    }


    // MARK: fetch install vendor
    static func fetchInstallVendor() -> String {
           #if targetEnvironment(simulator) || os(macOS) || targetEnvironment(macCatalyst)
           return "other"
           #else
           // MobileProvision profiles are a clear indicator for Ad-Hoc distribution.
           if hasEmbeddedMobileProvision() {
               return "other"
           }

           // TestFlight detection.
           if isAppStoreReceiptSandbox() {
               return "testFlight"
           }

           return "appStore"
           #endif
       }

    static func hasEmbeddedMobileProvision() -> Bool {
           return Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
       }

    
    static func isAppStoreReceiptSandbox() -> Bool {
           #if targetEnvironment(simulator)
           return false
           #else
           guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
               return false
           }
           return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
           #endif
       }
    
}


/// A utility class that generates and persists a unique device identifier (UID).
/// - First tries Keychain
/// - Falls back to UserDefaults
/// - Then to Apple Identifier for Vendor (IFV)
/// - Lastly generates a random UUID
private class DeviceUID {
    
    // Key for storing UID in Keychain and UserDefaults
    private static let uidKey = "deviceUID"
    
    private var uid: String?
    
    // MARK: - Public Methods
    
    /// Retrieves the persistent UID, generating and saving if needed.
    static func uid() -> String {
        return DeviceUID().getUid()
    }
    
    // MARK: - Private Initialization
    
    private init() {
        self.uid = nil
    }
    
    // MARK: - UID Retrieval
    
    /// Returns the UID, trying different fallback methods if needed.
    private func getUid() -> String {
        if uid == nil { uid = DeviceUID.valueFromKeychain(forKey: Self.uidKey, service: Self.uidKey) }
        if uid == nil { uid = DeviceUID.valueFromUserDefaults(forKey: Self.uidKey) }
        if uid == nil { uid = DeviceUID.appleIFV() }
        if uid == nil { uid = DeviceUID.randomUUID() }
        saveIfNeeded()
        return uid ?? ""
    }

    
    // MARK: - Persistence Helpers
    
    /// Save UID to both UserDefaults and Keychain unconditionally.
    private func save() {
        guard let uid = uid else { return }
        DeviceUID.setValue(uid, forUserDefaultsKey: Self.uidKey)
        DeviceUID.updateValue(uid, forKeychainKey: Self.uidKey, service: Self.uidKey)
    }
    
    /// Save UID to both UserDefaults and Keychain only if not already saved.
    private func saveIfNeeded() {
        if DeviceUID.valueFromUserDefaults(forKey: Self.uidKey) == nil {
            DeviceUID.setValue(uid ?? "", forUserDefaultsKey: Self.uidKey)
        }
        if DeviceUID.valueFromKeychain(forKey: Self.uidKey, service: Self.uidKey) == nil {
            DeviceUID.setValue(uid ?? "", forKeychainKey: Self.uidKey, service: Self.uidKey)
        }
    }
    
    // MARK: - Keychain Methods
    
    /// Builds a Keychain query dictionary.
    private static func keychainQuery(forKey key: String, service: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
    }
    
    /// Save a value to Keychain. Deletes the existing one if already present.
    @discardableResult
    private static func setValue(_ value: String, forKeychainKey key: String, service: String) -> OSStatus {
        var query = keychainQuery(forKey: key, service: service)
        query[kSecValueData as String] = value.data(using: .utf8)
        
        var status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            // If already exists, delete and try again
            _ = deleteValue(forKeychainKey: key, service: service)
            status = SecItemAdd(query as CFDictionary, nil)
        }
        return status
    }
    
    /// Update an existing Keychain value.
    @discardableResult
    private static func updateValue(_ value: String, forKeychainKey key: String, service: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: value.data(using: .utf8) ?? Data()
        ]
        return SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
    }
    
    /// Delete a value from Keychain.
    @discardableResult
    private static func deleteValue(forKeychainKey key: String, service: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
        return SecItemDelete(query as CFDictionary)
    }
    
    /// Retrieve a value from Keychain.
    private static func valueFromKeychain(forKey key: String, service: String) -> String? {
        var query = keychainQuery(forKey: key, service: service)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let dict = result as? [String: Any],
              let data = dict[kSecValueData as String] as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    // MARK: - UserDefaults Methods
    
    /// Save a value to UserDefaults.
    @discardableResult
    private static func setValue(_ value: String, forUserDefaultsKey key: String) -> Bool {
        UserDefaults.standard.set(value, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    
    /// Retrieve a value from UserDefaults.
    private static func valueFromUserDefaults(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    // MARK: - UID Generation Methods
    
    /// Fetch the Identifier For Vendor (IFV) provided by Apple.
    private static func appleIFV() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /// Generate a random UUID string.
    private static func randomUUID() -> String {
        return UUID().uuidString
    }
}
