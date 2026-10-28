import XCTest
@testable import AppsOnAir_AppRemark

class ShakeDetectorTests: XCTestCase {

    private let earthGravity = 9.80665
    private let allSensitivities: [ShakeSensitivity] = [.veryLow, .low, .medium, .high, .veryHigh]

    private var originalSensitivity: ShakeSensitivity!

    override func setUp() {
        super.setUp()
        originalSensitivity = ShakeDetector.shared.sensitivity
    }

    override func tearDown() {
        ShakeDetector.shared.sensitivity = originalSensitivity
        super.tearDown()
    }

    // MARK: - ShakeSensitivity
    func testRawValuesMatchObjCEnum() {
        XCTAssertEqual(ShakeSensitivity.veryLow.rawValue, 0)
        XCTAssertEqual(ShakeSensitivity.low.rawValue, 1)
        XCTAssertEqual(ShakeSensitivity.medium.rawValue, 2)
        XCTAssertEqual(ShakeSensitivity.high.rawValue, 3)
        XCTAssertEqual(ShakeSensitivity.veryHigh.rawValue, 4)
    }

    func testInitFromRawValue() {
        XCTAssertEqual(ShakeSensitivity(rawValue: 3), .high)
        XCTAssertNil(ShakeSensitivity(rawValue: 5))
        XCTAssertNil(ShakeSensitivity(rawValue: -1))
    }

    func testThresholdsMatchAndroidValuesInG() {
        XCTAssertEqual(ShakeSensitivity.veryLow.threshold, 32 / earthGravity, accuracy: 1e-9)
        XCTAssertEqual(ShakeSensitivity.low.threshold, 26 / earthGravity, accuracy: 1e-9)
        XCTAssertEqual(ShakeSensitivity.medium.threshold, 20 / earthGravity, accuracy: 1e-9)
        XCTAssertEqual(ShakeSensitivity.high.threshold, 16 / earthGravity, accuracy: 1e-9)
        XCTAssertEqual(ShakeSensitivity.veryHigh.threshold, 12 / earthGravity, accuracy: 1e-9)
    }

    func testHigherSensitivityNeedsLighterShake() {
        let thresholds = allSensitivities.map { $0.threshold }
        XCTAssertEqual(thresholds, thresholds.sorted(by: >), "threshold must decrease as sensitivity rises")
        XCTAssertEqual(Set(thresholds).count, allSensitivities.count, "thresholds must be distinct")
    }

    func testThresholdsArePositive() {
        allSensitivities.forEach { XCTAssertGreaterThan($0.threshold, 0) }
    }

    // MARK: - ShakeDetector
    func testSharedIsSingleton() {
        XCTAssertTrue(ShakeDetector.shared === ShakeDetector.shared)
    }

    func testStartStoresSensitivity() {
        allSensitivities.forEach {
            ShakeDetector.shared.start(sensitivity: $0)
            XCTAssertEqual(ShakeDetector.shared.sensitivity, $0)
        }
    }

    func testStartCanBeCalledRepeatedly() {
        ShakeDetector.shared.start(sensitivity: .low)
        ShakeDetector.shared.start(sensitivity: .veryHigh)
        XCTAssertEqual(ShakeDetector.shared.sensitivity, .veryHigh)
    }

    func testActiveOnlyWhenAccelerometerAvailable() {
        ShakeDetector.shared.start(sensitivity: .medium)
        if ShakeDetector.shared.isAvailable {
            XCTAssertTrue(ShakeDetector.shared.isActive)
        } else {
            // Simulator has no accelerometer, the system shake gesture keeps working
            XCTAssertFalse(ShakeDetector.shared.isActive)
        }
    }

    #if targetEnvironment(simulator)
        func testSimulatorHasNoAccelerometer() {
            XCTAssertFalse(ShakeDetector.shared.isAvailable)
            XCTAssertFalse(ShakeDetector.shared.isActive)
        }
    #endif
}
