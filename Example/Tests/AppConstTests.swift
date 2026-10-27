import XCTest
import UIKit
@testable import AppsOnAir_AppRemark

class AppConstTests: XCTestCase {

    // MARK: - EnvironmentConfig
    func testServerBaseURL() {
        XCTAssertEqual(EnvironmentConfig.serverBaseURl, "https://server.appsonair.com")
    }

    func testEndpointsAreBuiltFromBaseURL() {
        XCTAssertEqual(EnvironmentConfig.addFeedback, "https://server.appsonair.com/feedback")
        XCTAssertEqual(EnvironmentConfig.getSignInURL, "https://server.appsonair.com/signed-url")
    }

    func testEndpointsAreValidHTTPSURLs() {
        [EnvironmentConfig.addFeedback, EnvironmentConfig.getSignInURL].forEach {
            let url = URL(string: $0)
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.scheme, "https")
        }
    }

    // MARK: - Enums
    func testRemarkTypeRawValues() {
        XCTAssertEqual(RemarkType.suggestion.rawValue, "SUGGESTION")
        XCTAssertEqual(RemarkType.bug.rawValue, "BUG")
        XCTAssertEqual(RemarkType(rawValue: "BUG"), .bug)
        XCTAssertNil(RemarkType(rawValue: "bug"))
    }

    func testAPIStatusRawValues() {
        XCTAssertEqual(APIStatus.success.rawValue, "SUCCESS")
        XCTAssertEqual(APIStatus.failure.rawValue, "FAILURE")
        XCTAssertEqual(APIStatus(rawValue: "SUCCESS"), .success)
        XCTAssertNil(APIStatus(rawValue: "OK"))
    }

    // MARK: - Messages
    func testUserFacingMessages() {
        XCTAssertEqual(errorNetwork, "Please check internet connection")
        XCTAssertEqual(errorSomethingWentWrong, "Something went wrong, please try later!")
        XCTAssertEqual(errorGalleryPermission, "Gallery permission required!")
        XCTAssertEqual(chooseImageSource, "Choose your Image source")
        XCTAssertEqual(gallery, "Gallery")
        XCTAssertEqual(cancel, "Cancel")
        XCTAssertEqual(ok, "Ok")
        XCTAssertEqual(remark, "Remark")
        XCTAssertEqual(appsOnAirRemark, "AppsOnAir Remark")
        XCTAssertTrue(errorPhotosPermission.contains("NSPhotoLibraryUsageDescription"))
    }

    func testScreenSizeMatchesMainScreen() {
        XCTAssertEqual(screenWidth, UIScreen.main.bounds.size.width)
        XCTAssertEqual(screenHeight, UIScreen.main.bounds.size.height)
        XCTAssertGreaterThan(screenWidth, 0)
        XCTAssertGreaterThan(screenHeight, 0)
    }

    // MARK: - Bundle
    func testMainBundleHasPhotoPermission() {
        // Example app declares NSPhotoLibraryUsageDescription
        XCTAssertEqual(Bundle.main.photoPermission, true)
    }

    func testBundleWithoutPhotoPermission() {
        XCTAssertEqual(Bundle(for: AppConstTests.self).photoPermission, false)
    }

    func testMainBundleAppName() {
        XCTAssertEqual(Bundle.main.appName, "AppsOnAir-AppRemark_Example")
    }

    func testBundleWithoutDisplayNameHasNilAppName() {
        XCTAssertNil(Bundle(for: AppConstTests.self).appName)
    }

    func testRemarkBundleContainsResources() {
        let bundle = Bundle.remarkBundle
        XCTAssertNotNil(bundle.path(forResource: "AppRemark", ofType: "storyboardc"))
        XCTAssertNotNil(bundle.path(forResource: "ImageViewCell", ofType: "nib"))
        XCTAssertNotNil(bundle.path(forResource: "AddImageCVCell", ofType: "nib"))
        XCTAssertNotNil(UIImage(named: "ic_add", in: bundle, compatibleWith: nil))
        XCTAssertNotNil(UIImage(named: "ic_close", in: bundle, compatibleWith: nil))
    }

    func testRemarkBundleIsNotMainBundle() {
        XCTAssertNotEqual(Bundle.remarkBundle, Bundle.main)
    }

    func testRemarkBundleIsStable() {
        XCTAssertEqual(Bundle.remarkBundle.bundleURL, Bundle.remarkBundle.bundleURL)
    }
}
