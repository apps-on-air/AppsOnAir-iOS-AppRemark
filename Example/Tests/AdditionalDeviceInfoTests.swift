import XCTest
import UIKit
import Security
@testable import AppsOnAir_AppRemark

class AdditionalDeviceInfoTests: XCTestCase {

    private let uidKey = "deviceUID"

    override func tearDown() {
        MockURLProtocol.unregister()
        super.tearDown()
    }

    // MARK: - Permissions
    func testPermissionsInfoReportsDeclaredPhotoPermission() {
        let permissions = AdditionalDeviceInfo.permissionsInfo()

        // Example app declares only NSPhotoLibraryUsageDescription
        let status = permissions["NSPhotoLibraryUsageDescription"]
        XCTAssertNotNil(status)
        XCTAssertTrue(
            ["authorized", "limited", "denied", "notDetermined", "restricted", "unknown"].contains(status ?? ""))
    }

    func testPermissionsInfoOnlyContainsDeclaredKeys() {
        let permissions = AdditionalDeviceInfo.permissionsInfo()

        XCTAssertNil(permissions["NSCameraUsageDescription"], "camera is not declared")
        XCTAssertNil(permissions["UIBackgroundModes"], "background modes are not declared")
        permissions.keys.forEach {
            XCTAssertTrue($0.hasSuffix("UsageDescription") || $0 == "UIBackgroundModes", "unexpected key \($0)")
        }
    }

    func testBackgroundModesNilWhenNotDeclared() {
        XCTAssertNil(Bundle.main.infoDictionary?["UIBackgroundModes"])
        XCTAssertNil(AdditionalDeviceInfo.fetchBackgroundModes())
    }

    // MARK: - Biometry
    func testBiometryInfoKeys() {
        let info = AdditionalDeviceInfo.fetchBiometryInfo()

        XCTAssertNotNil(info["isBiometricSupported"])
        XCTAssertNotNil(info["isFaceIDAvailable"])
        XCTAssertNotNil(info["isTouchIDAvailable"])
        XCTAssertNotNil(info["isFaceIDEnrolled"])
        if #available(iOS 17.0, *) {
            XCTAssertNotNil(info["isOpticIDAvailable"])
        }
    }

    func testBiometryInfoIsConsistent() {
        let info = AdditionalDeviceInfo.fetchBiometryInfo()

        XCTAssertFalse(
            (info["isFaceIDAvailable"] ?? false) && (info["isTouchIDAvailable"] ?? false),
            "a device has one biometry type")
        if info["isFaceIDEnrolled"] == true {
            XCTAssertEqual(info["isFaceIDAvailable"], true)
            XCTAssertEqual(info["isBiometricSupported"], true)
        }
    }

    // MARK: - Font scale
    func testFontScaleIsKnownValue() {
        let known: [Float] = [0.82, 0.88, 0.95, 1.0, 1.12, 1.23, 1.35, 1.64, 1.95, 2.35, 2.76, 3.12]
        let scale = AdditionalDeviceInfo.fetchFontScale()

        XCTAssertTrue(known.contains { abs($0 - scale) < 0.001 }, "unexpected scale \(scale)")
    }

    func testFontScaleIsRoundedToTwoDecimals() {
        let scale = AdditionalDeviceInfo.fetchFontScale()
        XCTAssertEqual(scale, (scale * 100).rounded() / 100)
    }

    // MARK: - Locale
    func testLocaleDetailsFormat() {
        let locale = AdditionalDeviceInfo.fetchLocaleDetails()
        let parts = locale.split(separator: "_")

        XCTAssertEqual(parts.count, 2, "language_region expected, got \(locale)")
        XCTAssertFalse(parts.first?.isEmpty ?? true)
    }

    func testLocaleDetailsMatchesPreferredLanguage() {
        guard let preferred = Locale.preferredLanguages.first else { return }
        let language = Locale(identifier: preferred).languageCode ?? "unknown"

        XCTAssertTrue(AdditionalDeviceInfo.fetchLocaleDetails().hasPrefix("\(language)_"))
    }

    // MARK: - Theme
    func testThemeModeIsKnownValue() {
        XCTAssertTrue(["dark", "light", "Unspecified"].contains(AdditionalDeviceInfo.fetchThemeMode()))
    }

    func testThemeModeFollowsWindowStyle() {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return XCTFail("Host app has no window")
        }
        let original = window.overrideUserInterfaceStyle
        defer { window.overrideUserInterfaceStyle = original }

        window.overrideUserInterfaceStyle = .dark
        XCTAssertEqual(AdditionalDeviceInfo.fetchThemeMode(), "dark")
        window.overrideUserInterfaceStyle = .light
        XCTAssertEqual(AdditionalDeviceInfo.fetchThemeMode(), "light")
    }

    // MARK: - Install vendor
    #if targetEnvironment(simulator)
        func testInstallVendorOnSimulator() {
            XCTAssertEqual(AdditionalDeviceInfo.fetchInstallVendor(), "other")
            XCTAssertFalse(AdditionalDeviceInfo.isAppStoreReceiptSandbox())
            XCTAssertFalse(AdditionalDeviceInfo.hasEmbeddedMobileProvision())
        }
    #endif

    func testInstallVendorIsKnownValue() {
        XCTAssertTrue(["other", "testFlight", "appStore"].contains(AdditionalDeviceInfo.fetchInstallVendor()))
    }

    // MARK: - Device identifier
    func testDeviceIdentifierIsStable() {
        let first = AdditionalDeviceInfo.fetchDeviceIdentifier()

        XCTAssertFalse(first.isEmpty)
        XCTAssertEqual(AdditionalDeviceInfo.fetchDeviceIdentifier(), first)
        XCTAssertEqual(UserDefaults.standard.string(forKey: uidKey), first)
    }

    func testDeviceIdentifierRestoredFromKeychainWhenUserDefaultsCleared() {
        let original = AdditionalDeviceInfo.fetchDeviceIdentifier()
        UserDefaults.standard.removeObject(forKey: uidKey)

        XCTAssertEqual(AdditionalDeviceInfo.fetchDeviceIdentifier(), original)
        XCTAssertEqual(UserDefaults.standard.string(forKey: uidKey), original, "saved back to UserDefaults")
    }

    func testDeviceIdentifierRestoredFromUserDefaultsWhenKeychainCleared() {
        let original = AdditionalDeviceInfo.fetchDeviceIdentifier()
        deleteKeychainUID()

        XCTAssertEqual(AdditionalDeviceInfo.fetchDeviceIdentifier(), original)
        XCTAssertEqual(keychainUID(), original, "saved back to Keychain")
    }

    func testDeviceIdentifierFallsBackToVendorIdentifier() {
        let original = AdditionalDeviceInfo.fetchDeviceIdentifier()
        defer { restoreUID(original) }
        UserDefaults.standard.removeObject(forKey: uidKey)
        deleteKeychainUID()

        let identifier = AdditionalDeviceInfo.fetchDeviceIdentifier()

        XCTAssertEqual(identifier, UIDevice.current.identifierForVendor?.uuidString)
        XCTAssertEqual(UserDefaults.standard.string(forKey: uidKey), identifier)
        XCTAssertEqual(keychainUID(), identifier)
    }

    // MARK: - Public IP
    func testFetchPublicIpReturnsBody() {
        MockURLProtocol.register()
        MockURLProtocol.handler = { _ in .init(data: Data("203.0.113.7".utf8)) }
        let done = expectation(description: "ip")

        AdditionalDeviceInfo.fetchPublicIp { ip in
            XCTAssertEqual(ip, "203.0.113.7")
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        XCTAssertEqual(MockURLProtocol.requests.first?.url?.host, "api.ipify.org")
    }

    func testFetchPublicIpReturnsNilOnError() {
        MockURLProtocol.register()
        MockURLProtocol.handler = { _ in .init(error: URLError(.notConnectedToInternet)) }
        let done = expectation(description: "ip")

        AdditionalDeviceInfo.fetchPublicIp { ip in
            XCTAssertNil(ip)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testFetchPublicIpReturnsNilForNonUTF8Body() {
        MockURLProtocol.register()
        MockURLProtocol.handler = { _ in .init(data: Data([0xFF, 0xFE, 0xFD])) }
        let done = expectation(description: "ip")

        AdditionalDeviceInfo.fetchPublicIp { ip in
            XCTAssertNil(ip)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    // MARK: - Keychain helpers (same query as DeviceUID)
    private func keychainQuery() -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: uidKey,
            kSecAttrService as String: uidKey,
        ]
    }

    private func deleteKeychainUID() {
        SecItemDelete(keychainQuery() as CFDictionary)
    }

    private func keychainUID() -> String? {
        var query = keychainQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func restoreUID(_ uid: String) {
        deleteKeychainUID()
        UserDefaults.standard.set(uid, forKey: uidKey)
        _ = AdditionalDeviceInfo.fetchDeviceIdentifier()
    }
}
