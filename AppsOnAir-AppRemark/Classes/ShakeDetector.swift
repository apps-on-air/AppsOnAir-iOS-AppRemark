#if canImport(UIKit)
    import UIKit
    import CoreMotion
    import AppsOnAir_Core

    /// set how hard the device must be shaken to open the remark screen, when not set the system shake gesture is used
    @objc public enum ShakeSensitivity: Int {
        case veryLow, low, medium, high, veryHigh

        private static let earthGravity = 9.80665

        /// smoothed acceleration change (in g) a shake must exceed, same values as Android SDK (m/s²) converted to g
        var threshold: Double {
            switch self {
            case .veryLow: return 32 / Self.earthGravity
            case .low: return 26 / Self.earthGravity
            case .medium: return 20 / Self.earthGravity
            case .high: return 16 / Self.earthGravity
            case .veryHigh: return 12 / Self.earthGravity
            }
        }
    }

    /// help to detect shake from accelerometer data, as the system shake gesture threshold can not be configured
    final class ShakeDetector {
        static let shared = ShakeDetector()

        private let motionManager = CMMotionManager()
        /// can be changed while detecting, the next accelerometer update uses it
        var sensitivity = ShakeSensitivity.medium
        private var accel: Double = 0
        private var accelCurrent: Double = 1
        private var accelLast: Double = 1

        // a shake keeps the device moving, putting it down (even on a sofa that bounces) settles within ~0.3s
        // same values as Android SDK, tolerance converted from m/s² to g
        private let stillTolerance = 3 / 9.80665
        private let confirmFrom: TimeInterval = 0.35
        private let confirmUntil: TimeInterval = 0.8
        private var joltTimestamp: TimeInterval?

        /// false where there is no accelerometer (eg: Simulator)
        var isAvailable: Bool {
            return motionManager.isAccelerometerAvailable
        }

        /// true once a sensitivity is set on a device with accelerometer, otherwise system shake gesture is used
        var isActive: Bool {
            return motionManager.isAccelerometerActive
        }

        func start(sensitivity: ShakeSensitivity) {
            self.sensitivity = sensitivity
            guard isAvailable, !motionManager.isAccelerometerActive else { return }

            // same sampling rate as Android SENSOR_DELAY_NORMAL so the thresholds behave alike on both platforms
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data else { return }
                let acceleration = data.acceleration
                self.accelLast = self.accelCurrent
                self.accelCurrent = sqrt(
                    acceleration.x * acceleration.x + acceleration.y * acceleration.y
                        + acceleration.z * acceleration.z)
                self.accel = self.accel * 0.9 + (self.accelCurrent - self.accelLast)

                if let joltTimestamp = self.joltTimestamp {
                    let elapsed = data.timestamp - joltTimestamp
                    let deviation = abs(self.accelCurrent - 1)
                    if elapsed > self.confirmUntil {
                        // device settled, it was put down and not shaken
                        self.joltTimestamp = nil
                    } else if elapsed >= self.confirmFrom && deviation > self.stillTolerance {
                        self.joltTimestamp = nil
                        self.accel = 0
                        Logger.logInternal(shakeGestureDetected)
                        UIApplication.topViewController()?.handleShakeGesture()
                    }
                } else if self.accel > self.sensitivity.threshold {
                    // wait to tell a shake (keeps moving) from putting the device down (settles)
                    self.joltTimestamp = data.timestamp
                }
            }
        }
    }
#endif
