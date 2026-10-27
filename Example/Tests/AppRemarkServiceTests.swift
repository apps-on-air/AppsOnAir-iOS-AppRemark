import XCTest
import UIKit
@testable import AppsOnAir_AppRemark

class AppRemarkServiceTests: XCTestCase {

    private var snapshot: ServiceSnapshot!
    private var originalDetectorSensitivity: ShakeSensitivity!
    private var originalFeedbackInProgress = false

    private let fullOptions: NSDictionary = [
        "appBarBackgroundColor": "#1c1c9e",
        "appBarTitleText": "Feedback Screen",
        "appBarTitleColor": "#FFFFFF",
        "pageBackgroundColor": "#007AFF",
        "remarkTypeLabelText": "Add Remark here",
        "labelColor": "#EEEEEE",
        "hintColor": "#DDDDDD",
        "descriptionLabelText": "Add description here",
        "descriptionMaxLength": 120,
        "descriptionHintText": "Add description here..",
        "inputTextColor": "#000000",
        "buttonText": "Submit Remark",
        "buttonTextColor": "#111111",
        "buttonBackgroundColor": "#222222",
    ]

    override func setUp() {
        super.setUp()
        snapshot = ServiceSnapshot(AppRemarkService.shared)
        originalDetectorSensitivity = ShakeDetector.shared.sensitivity
        originalFeedbackInProgress = isFeedbackInProgress
    }

    override func tearDown() {
        snapshot.restore(AppRemarkService.shared)
        ShakeDetector.shared.sensitivity = originalDetectorSensitivity
        isFeedbackInProgress = originalFeedbackInProgress
        super.tearDown()
    }

    // MARK: - Shared instance
    func testSharedIsSingleton() {
        XCTAssertTrue(AppRemarkService.shared === AppRemarkService.shared)
    }

    func testSharedUsesAppIdFromInfoPlist() {
        let expected = Bundle.main.infoDictionary?["AppsonairAppId"] as? String
        XCTAssertNotNil(expected)
        XCTAssertEqual(AppRemarkService.shared.appsOnAirCore.appId, expected)
    }

    // MARK: - initialize options
    func testInitializeAppliesAllOptions() {
        let service = AppRemarkService()
        service.initialize(options: fullOptions) { _ in }

        XCTAssertEqual(service.appBarBackgroundColor, "#1c1c9e")
        XCTAssertEqual(service.appBarTitleText, "Feedback Screen")
        XCTAssertEqual(service.appBarTitleColor, "#FFFFFF")
        XCTAssertEqual(service.pageBackgroundColor, "#007AFF")
        XCTAssertEqual(service.remarkTypeLabelText, "Add Remark here")
        XCTAssertEqual(service.labelColor, "#EEEEEE")
        XCTAssertEqual(service.hintColor, "#DDDDDD")
        XCTAssertEqual(service.descriptionLabelText, "Add description here")
        XCTAssertEqual(service.descriptionMaxLength, 120)
        XCTAssertEqual(service.descriptionHintText, "Add description here..")
        XCTAssertEqual(service.inputTextColor, "#000000")
        XCTAssertEqual(service.buttonText, "Submit Remark")
        XCTAssertEqual(service.buttonTextColor, "#111111")
        XCTAssertEqual(service.buttonBackgroundColor, "#222222")
    }

    func testInitializeOptionKeysAreCaseInsensitive() {
        let service = AppRemarkService()
        service.initialize(options: [
            "APPBARTITLETEXT": "Upper",
            "buttontext": "lower",
            "DescriptionMaxLength": 10,
        ]) { _ in }

        XCTAssertEqual(service.appBarTitleText, "Upper")
        XCTAssertEqual(service.buttonText, "lower")
        XCTAssertEqual(service.descriptionMaxLength, 10)
    }

    func testInitializeWithoutOptionsKeepsDefaults() {
        let service = AppRemarkService()
        service.initialize { _ in }

        XCTAssertNil(service.appBarBackgroundColor)
        XCTAssertNil(service.appBarTitleText)
        XCTAssertNil(service.appBarTitleColor)
        XCTAssertNil(service.pageBackgroundColor)
        XCTAssertNil(service.remarkTypeLabelText)
        XCTAssertNil(service.labelColor)
        XCTAssertNil(service.hintColor)
        XCTAssertNil(service.descriptionLabelText)
        XCTAssertNil(service.descriptionMaxLength)
        XCTAssertNil(service.descriptionHintText)
        XCTAssertNil(service.inputTextColor)
        XCTAssertNil(service.buttonText)
        XCTAssertNil(service.buttonTextColor)
        XCTAssertNil(service.buttonBackgroundColor)
        XCTAssertNil(service.additionalParams)
    }

    func testInitializeIgnoresValuesOfWrongType() {
        let service = AppRemarkService()
        service.initialize(options: [
            "buttonText": 42,
            "appBarTitleText": ["nested"],
            "descriptionMaxLength": "100",
        ]) { _ in }

        XCTAssertNil(service.buttonText)
        XCTAssertNil(service.appBarTitleText)
        XCTAssertNil(service.descriptionMaxLength)
    }

    func testInitializeIgnoresNonStringKeys() {
        let service = AppRemarkService()
        service.initialize(options: [1: "value", "buttonText": "Send"]) { _ in }

        XCTAssertEqual(service.buttonText, "Send")
    }

    func testInitializeIgnoresUnknownKeys() {
        let service = AppRemarkService()
        service.initialize(options: ["unknownOption": "x", "hintColor": "#123456"]) { _ in }

        XCTAssertEqual(service.hintColor, "#123456")
    }

    func testInitializeKeepsNegativeMaxLengthForScreenToFallback() {
        let service = AppRemarkService()
        service.initialize(options: ["descriptionMaxLength": -1]) { _ in }

        XCTAssertEqual(service.descriptionMaxLength, -1)
    }

    func testSecondInitializeDoesNotOverrideOptions() {
        // current behavior: once the listener exists, later initialize calls return early
        let service = AppRemarkService()
        service.initialize(options: ["buttonText": "First"]) { _ in }
        service.initialize(shakeGestureEnable: false, options: ["buttonText": "Second"]) { _ in }

        XCTAssertEqual(service.buttonText, "First")
        XCTAssertEqual(service.shakeGestureEnable, true)
    }

    func testInitializeLoadsAppIdFromInfoPlist() {
        let service = AppRemarkService()
        service.initialize { _ in }

        XCTAssertEqual(
            service.appsOnAirCore.appId, Bundle.main.infoDictionary?["AppsonairAppId"] as? String)
    }

    // MARK: - Shake configuration
    func testShakeGestureEnabledByDefault() {
        let service = AppRemarkService()
        service.initialize { _ in }

        XCTAssertEqual(service.shakeGestureEnable, true)
        XCTAssertNil(service.shakeSensitivity, "system shake gesture is used without sensitivity")
    }

    func testShakeGestureCanBeDisabled() {
        let service = AppRemarkService()
        service.initialize(shakeGestureEnable: false) { _ in }

        XCTAssertEqual(service.shakeGestureEnable, false)
    }

    func testInitializeWithSensitivityStartsDetector() {
        ShakeDetector.shared.sensitivity = .medium
        let service = AppRemarkService()
        service.initialize(shakeSensitivity: .veryHigh) { _ in }

        XCTAssertEqual(service.shakeSensitivity, .veryHigh)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .veryHigh)
    }

    func testInitializeWithSensitivityButShakeDisabledDoesNotStartDetector() {
        ShakeDetector.shared.sensitivity = .medium
        let service = AppRemarkService()
        service.initialize(shakeGestureEnable: false, shakeSensitivity: .veryLow) { _ in }

        XCTAssertEqual(service.shakeSensitivity, .veryLow)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .medium)
    }

    func testSetShakeSensitivityUpdatesDetectorWhenShakeEnabled() {
        let service = AppRemarkService()
        service.initialize { _ in }
        service.setShakeSensitivity(.low)

        XCTAssertEqual(service.shakeSensitivity, .low)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .low)
    }

    func testSetShakeSensitivityAtRuntimeCanChangeRepeatedly() {
        let service = AppRemarkService()
        service.initialize(shakeSensitivity: .low) { _ in }
        service.setShakeSensitivity(.high)
        service.setShakeSensitivity(.veryLow)

        XCTAssertEqual(service.shakeSensitivity, .veryLow)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .veryLow)
    }

    func testSetShakeSensitivityDoesNotStartDetectorWhenShakeDisabled() {
        ShakeDetector.shared.sensitivity = .medium
        let service = AppRemarkService()
        service.initialize(shakeGestureEnable: false) { _ in }
        service.setShakeSensitivity(.veryHigh)

        XCTAssertEqual(service.shakeSensitivity, .veryHigh)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .medium)
    }

    func testSetShakeSensitivityBeforeInitializeOnlyStoresValue() {
        ShakeDetector.shared.sensitivity = .medium
        let service = AppRemarkService()
        service.setShakeSensitivity(.high)

        XCTAssertEqual(service.shakeSensitivity, .high)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .medium)
    }

    func testSensitivitySetBeforeInitializeIsKeptWhenInitializeHasNone() {
        let service = AppRemarkService()
        service.setShakeSensitivity(.high)
        service.initialize { _ in }

        XCTAssertEqual(service.shakeSensitivity, .high)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .high)
    }

    // MARK: - Remark response listener
    func testListenerReceivesRemarkResponseOnMainThread() {
        let service = AppRemarkService()
        let received = expectation(description: "response")
        service.initialize { response in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(response["status"] as? String, "SUCCESS")
            XCTAssertEqual(response["message"] as? String, "Done")
            received.fulfill()
        }

        service.remarkResponse = ["status": "SUCCESS", "message": "Done"]
        wait(for: [received], timeout: 2)
    }

    func testListenerSkipsInitialValue() {
        let service = AppRemarkService()
        let notCalled = expectation(description: "not called")
        notCalled.isInverted = true
        service.initialize { _ in notCalled.fulfill() }

        wait(for: [notCalled], timeout: 0.5)
    }

    func testListenerReceivesEmptyDictionaryForNilResponse() {
        let service = AppRemarkService()
        let received = expectation(description: "response")
        service.initialize { response in
            XCTAssertTrue(response.isEmpty)
            received.fulfill()
        }

        service.remarkResponse = nil
        wait(for: [received], timeout: 2)
    }

    func testListenerReceivesEveryResponse() {
        let service = AppRemarkService()
        let received = expectation(description: "responses")
        received.expectedFulfillmentCount = 2
        var statuses: [String] = []
        service.initialize { response in
            statuses.append(response["status"] as? String ?? "")
            received.fulfill()
        }

        service.remarkResponse = ["status": "FAILURE"]
        let delivered = expectation(description: "first delivered")
        DispatchQueue.main.async { delivered.fulfill() }
        wait(for: [delivered], timeout: 1)
        service.remarkResponse = ["status": "SUCCESS"]
        wait(for: [received], timeout: 2)
        XCTAssertEqual(statuses, ["FAILURE", "SUCCESS"])
    }

    func testListenerDeliversLatestValueForBackToBackResponses() {
        // current behavior: the callback reads remarkResponse when the main queue runs it,
        // so updates set before delivery are all reported with the latest value
        let service = AppRemarkService()
        let received = expectation(description: "responses")
        received.expectedFulfillmentCount = 2
        var statuses: [String] = []
        service.initialize { response in
            statuses.append(response["status"] as? String ?? "")
            received.fulfill()
        }

        service.remarkResponse = ["status": "FAILURE"]
        service.remarkResponse = ["status": "SUCCESS"]
        wait(for: [received], timeout: 2)
        XCTAssertEqual(statuses, ["SUCCESS", "SUCCESS"])
    }

    func testOnlyFirstInitializeCallbackIsUsed() {
        let service = AppRemarkService()
        let first = expectation(description: "first")
        let second = expectation(description: "second")
        second.isInverted = true
        service.initialize { _ in first.fulfill() }
        service.initialize { _ in second.fulfill() }

        service.remarkResponse = ["status": "SUCCESS"]
        wait(for: [first, second], timeout: 1)
    }

    func testServiceIsReleasedAfterInitialize() {
        weak var weakService: AppRemarkService?
        autoreleasepool {
            let service = AppRemarkService()
            service.initialize { _ in }
            weakService = service
        }
        // pending main queue blocks capture nothing strong, the listener captures self weakly
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { drained.fulfill() }
        wait(for: [drained], timeout: 1)
        XCTAssertNil(weakService)
    }

    // MARK: - setAdditionalMetaData
    func testSetAdditionalMetaDataStoresPayload() {
        let service = AppRemarkService()
        service.setAdditionalMetaData(extraPayload: ["userId": "USER_ID", "isShake": true])

        XCTAssertEqual(service.additionalParams?["userId"] as? String, "USER_ID")
        XCTAssertEqual(service.additionalParams?["isShake"] as? Bool, true)
    }

    func testSetAdditionalMetaDataReplacesPreviousPayload() {
        let service = AppRemarkService()
        service.setAdditionalMetaData(extraPayload: ["a": 1])
        service.setAdditionalMetaData(extraPayload: ["b": 2])

        XCTAssertNil(service.additionalParams?["a"])
        XCTAssertEqual(service.additionalParams?["b"] as? Int, 2)
    }

    func testSetAdditionalMetaDataWithEmptyPayload() {
        let service = AppRemarkService()
        service.setAdditionalMetaData(extraPayload: [:])

        XCTAssertNotNil(service.additionalParams)
        XCTAssertEqual(service.additionalParams?.isEmpty, true)
    }

    func testSetAdditionalMetaDataWithNonStringKeysIsNil() {
        let service = AppRemarkService()
        service.setAdditionalMetaData(extraPayload: [1: "one"])

        XCTAssertNil(service.additionalParams)
    }

    func testSetAdditionalMetaDataKeepsNestedValues() {
        let service = AppRemarkService()
        service.setAdditionalMetaData(extraPayload: ["user": ["id": 7, "tags": ["a", "b"]]])

        let user = service.additionalParams?["user"] as? [String: Any]
        XCTAssertEqual(user?["id"] as? Int, 7)
        XCTAssertEqual(user?["tags"] as? [String], ["a", "b"])
    }

    // MARK: - addRemark
    func testAddRemarkPresentsRemarkScreenOnTopController() {
        guard let top = UIApplication.topViewController() else {
            return XCTFail("Host app has no top view controller")
        }
        let notified = expectation(forNotification: NSNotification.Name("visibilityChanges"), object: nil) {
            $0.userInfo?["isPresented"] as? Bool == true
        }

        AppRemarkService.shared.addRemark()
        wait(for: [notified], timeout: 2)

        let presentedPredicate = NSPredicate { _, _ in top.presentedViewController is RemarkController }
        wait(for: [expectation(for: presentedPredicate, evaluatedWith: nil)], timeout: 5)

        let dismissed = expectation(description: "dismissed")
        top.dismiss(animated: false) { dismissed.fulfill() }
        wait(for: [dismissed], timeout: 5)
    }

    // MARK: - Objective-C interface used by the ObjC bridge
    func testObjCRuntimeNameMatchesBridgeLookup() {
        XCTAssertTrue(NSClassFromString("AppsOnAir_AppRemark.AppRemarkService") === AppRemarkService.self)
    }

    func testObjCSelectorsExist() {
        let service = AppRemarkService.shared
        [
            "initializeWithShakeGestureEnable:options:onRemarkResponse:",
            "initializeWithShakeGestureEnable:options:shakeSensitivity:onRemarkResponse:",
            "addRemark",
            "setAdditionalMetaDataWithExtraPayload:",
            "setShakeSensitivity:",
        ].forEach {
            XCTAssertTrue(service.responds(to: NSSelectorFromString($0)), "missing selector \($0)")
        }
        XCTAssertTrue(AppRemarkService.responds(to: NSSelectorFromString("shared")))
    }
}
