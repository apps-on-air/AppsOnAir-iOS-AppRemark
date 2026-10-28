import XCTest
import UIKit
import LWPhotoEditor
@testable import AppsOnAir_AppRemark

class ExtensionsTests: XCTestCase {

    private let visibilityChanges = NSNotification.Name("visibilityChanges")
    private var originalFeedbackInProgress = false
    private var originalShakeGestureEnable: Bool?

    override func setUp() {
        super.setUp()
        originalFeedbackInProgress = isFeedbackInProgress
        originalShakeGestureEnable = AppRemarkService.shared.shakeGestureEnable
        isFeedbackInProgress = false
    }

    override func tearDown() {
        isFeedbackInProgress = originalFeedbackInProgress
        AppRemarkService.shared.shakeGestureEnable = originalShakeGestureEnable
        super.tearDown()
    }

    // MARK: - UIImage
    func testFileTypeIsPNGForBitmapImage() {
        XCTAssertEqual(TestHelper.makeImage().getFileType(), "png")
    }

    func testFileTypeIsNilForEmptyImage() {
        XCTAssertNil(UIImage().getFileType())
    }

    func testImageSizeReturnsPNGData() {
        let image = TestHelper.makeImage(size: CGSize(width: 20, height: 30))
        let data = image.getImageSize()
        XCTAssertNotNil(data)
        XCTAssertEqual(data, image.pngData())
        XCTAssertGreaterThan(data?.count ?? 0, 0)
    }

    func testImageSizeIsNilForEmptyImage() {
        XCTAssertNil(UIImage().getImageSize())
    }

    func testImageSizeGrowsWithImage() {
        let small = TestHelper.makeImage(size: CGSize(width: 2, height: 2)).getImageSize()?.count ?? 0
        let noisy = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200)).image { ctx in
            for x in stride(from: 0, to: 200, by: 4) {
                UIColor(hue: CGFloat(x) / 200, saturation: 1, brightness: 1, alpha: 1).setFill()
                ctx.fill(CGRect(x: x, y: 0, width: 4, height: 200))
            }
        }
        XCTAssertGreaterThan(noisy.getImageSize()?.count ?? 0, small)
    }

    // MARK: - UIView
    func testAddShadow() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.addShadow()

        XCTAssertFalse(view.layer.masksToBounds)
        XCTAssertEqual(view.layer.shadowRadius, 8)
        XCTAssertEqual(view.layer.shadowOpacity, 1)
        XCTAssertEqual(view.layer.shadowColor, UIColor.gray.cgColor)
        XCTAssertEqual(view.layer.shadowOffset, CGSize(width: 0, height: 2))
        XCTAssertEqual(
            view.layer.shadowPath?.boundingBox, CGRect(x: 0, y: 42, width: screenWidth, height: 8))
    }

    func testAddShadowsDefaults() {
        let view = UIView()
        view.addShadows()

        XCTAssertEqual(view.layer.cornerRadius, 0)
        XCTAssertEqual(view.layer.shadowColor, UIColor.black.cgColor)
        XCTAssertEqual(view.layer.shadowOffset, CGSize(width: 1, height: 2))
        XCTAssertEqual(view.layer.shadowOpacity, 0.4)
        XCTAssertEqual(view.layer.shadowRadius, 3)
    }

    func testAddShadowsCustomValues() {
        let view = UIView()
        view.addShadows(
            shadowColor: UIColor.red.cgColor, shadowOffset: CGSize(width: 5, height: 3),
            shadowOpacity: 0.9, shadowRadius: 6, cornerRadiusIs: 6)

        XCTAssertEqual(view.layer.cornerRadius, 6)
        XCTAssertEqual(view.layer.shadowColor, UIColor.red.cgColor)
        XCTAssertEqual(view.layer.shadowOffset, CGSize(width: 5, height: 3))
        XCTAssertEqual(view.layer.shadowOpacity, 0.9)
        XCTAssertEqual(view.layer.shadowRadius, 6)
    }

    func testAddCornerRadiusDefaults() {
        let view = UIView()
        view.addCornerRadius(raduis: nil)

        XCTAssertEqual(view.layer.cornerRadius, 8)
        XCTAssertEqual(view.layer.borderWidth, 1)
        XCTAssertTrue(view.layer.masksToBounds)
        XCTAssertEqual(view.layer.borderColor, UIColor.lightGray.cgColor)
    }

    func testAddCornerRadiusCustomValues() {
        let view = UIView()
        view.addCornerRadius(color: .clear, raduis: 0)

        XCTAssertEqual(view.layer.cornerRadius, 0)
        XCTAssertEqual(view.layer.borderColor, UIColor.clear.cgColor)
    }

    func testRoundCornersAddsMask() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        view.roundCorners([.topLeft, .topRight], radius: 10)

        let mask = view.layer.mask as? CAShapeLayer
        XCTAssertNotNil(mask)
        XCTAssertEqual(mask?.path?.boundingBox, view.bounds)
    }

    func testTakeScreenshotHasScreenSize() {
        let screenshot = UIView().takeScreenshot()
        XCTAssertNotNil(screenshot)
        XCTAssertEqual(screenshot?.size, UIScreen.main.bounds.size)
    }

    // MARK: - UIDevice
    func testModelIdentifierIsNotEmpty() {
        XCTAssertFalse(UIDevice.current.modelIdentifier.isEmpty)
    }

    #if targetEnvironment(simulator)
        func testModelIdentifierOnSimulator() {
            XCTAssertTrue(UIDevice.current.modelIdentifier.hasPrefix("Simulator"))
        }
    #endif

    // MARK: - UIApplication
    func testActiveWindowIsKeyWindow() {
        let window = UIApplication.shared.activeWindow
        XCTAssertNotNil(window)
        XCTAssertEqual(window?.isKeyWindow, true)
    }

    func testTopViewControllerOfNilIsNil() {
        XCTAssertNil(UIApplication.topViewController(base: nil))
    }

    func testTopViewControllerReturnsPlainController() {
        let vc = UIViewController()
        XCTAssertTrue(UIApplication.topViewController(base: vc) === vc)
    }

    func testTopViewControllerOfNavigationIsVisibleController() {
        let root = UIViewController()
        let top = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.pushViewController(top, animated: false)

        XCTAssertTrue(UIApplication.topViewController(base: nav) === top)
    }

    func testTopViewControllerOfTabBarIsSelectedController() {
        let first = UIViewController()
        let second = UIViewController()
        let tab = UITabBarController()
        tab.viewControllers = [first, second]
        tab.selectedIndex = 1

        XCTAssertTrue(UIApplication.topViewController(base: tab) === second)
    }

    func testTopViewControllerOfEmptyTabBarIsTabBar() {
        let tab = UITabBarController()
        XCTAssertTrue(UIApplication.topViewController(base: tab) === tab)
    }

    func testTopViewControllerOfTabBarWithNavigation() {
        let top = UIViewController()
        let nav = UINavigationController(rootViewController: top)
        let tab = UITabBarController()
        tab.viewControllers = [nav]

        XCTAssertTrue(UIApplication.topViewController(base: tab) === top)
    }

    func testTopViewControllerFollowsPresentedController() {
        let presented = UIViewController()
        let base = PresentingStubViewController(stubPresented: presented)

        XCTAssertTrue(UIApplication.topViewController(base: base) === presented)
    }

    func testTopViewControllerDefaultsToActiveWindow() {
        XCTAssertNotNil(UIApplication.topViewController())
    }

    // MARK: - UIViewController presentation
    func testPresentScreenFromTopUsesOverFullScreen() {
        let spy = PresentationSpyViewController()
        let target = UIViewController()
        let completed = expectation(description: "completion")

        spy.presentScreenFromTop(target) { completed.fulfill() }
        wait(for: [completed], timeout: 2)

        XCTAssertEqual(target.modalPresentationStyle, .overFullScreen)
        XCTAssertTrue(spy.presentedControllers.first === target)
    }

    func testPresentScreenFromTopIsAsync() {
        let spy = PresentationSpyViewController()
        spy.presentScreenFromTop(UIViewController())
        XCTAssertTrue(spy.presentedControllers.isEmpty, "presentation is dispatched to main queue")
    }

    func testShowToastCallsCompletionWithSuccess() {
        let vc = UIViewController()
        vc.view.frame = UIScreen.main.bounds
        let completed = expectation(description: "completion")

        vc.showToast(message: "Hello") { success in
            XCTAssertTrue(success)
            completed.fulfill()
        }
        wait(for: [completed], timeout: 2)
        XCTAssertFalse(vc.view.subviews.isEmpty, "toast view is added")
    }

    func testShowToastWithoutCompletion() {
        let vc = UIViewController()
        vc.view.frame = UIScreen.main.bounds
        vc.showToast(message: "Hello", duration: 0.1)

        let shown = expectation(description: "toast shown")
        DispatchQueue.main.async { shown.fulfill() }
        wait(for: [shown], timeout: 2)
        XCTAssertFalse(vc.view.subviews.isEmpty)
    }

    func testSelectImagePopupPresentsActionSheet() {
        let spy = PresentationSpyViewController()
        spy.selectImagePopup()

        let alert = spy.presentedControllers.first as? UIAlertController
        XCTAssertNotNil(alert)
        XCTAssertNil(alert?.title)
        XCTAssertEqual(alert?.message, chooseImageSource)
        XCTAssertEqual(alert?.preferredStyle, .actionSheet)
        XCTAssertEqual(alert?.actions.map { $0.title }, [gallery, cancel])
        XCTAssertEqual(alert?.actions.map { $0.style }, [.default, .destructive])
    }

    func testSelectImagePopupWithCustomTitle() {
        let spy = PresentationSpyViewController()
        spy.selectImagePopup("Pick one")

        XCTAssertEqual((spy.presentedControllers.first as? UIAlertController)?.message, "Pick one")
    }

    func testCheckGalleryPermissionWithoutAskingPresentsNothing() {
        let spy = PresentationSpyViewController()
        spy.checkGalleryPermission()
        XCTAssertTrue(spy.presentedControllers.isEmpty)
    }

    // MARK: - showRemarkScreen
    func testShowRemarkScreenPresentsRemarkController() {
        let remarkController = presentRemarkScreen(screenshot: nil)

        XCTAssertNotNil(remarkController)
        XCTAssertEqual(remarkController?.modalPresentationStyle, .overFullScreen)
        XCTAssertEqual(remarkController?.selectedImage?.count, 0)
    }

    func testShowRemarkScreenAttachesScreenshot() {
        let screenshot = TestHelper.makeImage()
        let remarkController = presentRemarkScreen(screenshot: screenshot)

        XCTAssertEqual(remarkController?.selectedImage?.count, 1)
        XCTAssertTrue(remarkController?.selectedImage?.first === screenshot)
    }

    func testShowRemarkScreenCopiesCustomization() {
        let service = AppRemarkService.shared
        let snapshot = ServiceSnapshot(service)
        defer { snapshot.restore(service) }

        service.appBarBackgroundColor = "#111111"
        service.appBarTitleText = "Title"
        service.appBarTitleColor = "#222222"
        service.remarkTypeLabelText = "Type"
        service.labelColor = "#333333"
        service.hintColor = "#444444"
        service.pageBackgroundColor = "#555555"
        service.inputTextColor = "#666666"
        service.descriptionLabelText = "Desc"
        service.descriptionMaxLength = 50
        service.descriptionHintText = "Hint"
        service.buttonText = "Send"
        service.buttonTextColor = "#777777"
        service.buttonBackgroundColor = "#888888"

        let vc = presentRemarkScreen(screenshot: nil)

        XCTAssertEqual(vc?.appBarBackgroundColor, "#111111")
        XCTAssertEqual(vc?.appBarTitleText, "Title")
        XCTAssertEqual(vc?.appBarTitleColor, "#222222")
        XCTAssertEqual(vc?.lblTicketText, "Type")
        XCTAssertEqual(vc?.labelColor, "#333333")
        XCTAssertEqual(vc?.hintColor, "#444444")
        XCTAssertEqual(vc?.pageBackgroundColor, "#555555")
        XCTAssertEqual(vc?.inputTextColor, "#666666")
        XCTAssertEqual(vc?.descriptionLabelText, "Desc")
        XCTAssertEqual(vc?.txtDescriptionCharLimit, 50)
        XCTAssertEqual(vc?.txtDescriptionHintText, "Hint")
        XCTAssertEqual(vc?.buttonText, "Send")
        XCTAssertEqual(vc?.buttonTextColor, "#777777")
        XCTAssertEqual(vc?.buttonBackgroundColor, "#888888")
    }

    func testShowRemarkScreenUsesDefaultLimitForMissingOrInvalidMaxLength() {
        let service = AppRemarkService.shared
        let snapshot = ServiceSnapshot(service)
        defer { snapshot.restore(service) }

        [nil, 0, -10].forEach { limit in
            service.descriptionMaxLength = limit
            XCTAssertEqual(
                presentRemarkScreen(screenshot: nil)?.txtDescriptionCharLimit, 255,
                "limit \(String(describing: limit)) falls back to 255")
        }
        service.descriptionMaxLength = 1
        XCTAssertEqual(presentRemarkScreen(screenshot: nil)?.txtDescriptionCharLimit, 1)
    }

    // MARK: - Shake handling
    func testHandleShakeGestureIgnoredWhileFeedbackInProgress() {
        isFeedbackInProgress = true
        let spy = PresentationSpyViewController()
        let notified = expectation(forNotification: visibilityChanges, object: nil)
        notified.isInverted = true

        spy.handleShakeGesture()

        wait(for: [notified], timeout: 0.5)
        XCTAssertTrue(spy.presentedControllers.isEmpty)
    }

    func testHandleShakeGesturePresentsImageEditor() {
        let spy = PresentationSpyViewController()
        let notified = expectation(forNotification: visibilityChanges, object: nil) { note in
            note.userInfo?["isPresented"] as? Bool == true
        }

        spy.handleShakeGesture()

        wait(for: [notified], timeout: 2)
        let editor = spy.presentedControllers.first as? ZLEditImageViewController
        XCTAssertNotNil(editor)
        XCTAssertTrue(isFeedbackInProgress, "screenshot of key window marks feedback in progress")
    }

    func testFinishingImageEditOpensRemarkScreenWithEditedImage() {
        let spy = PresentationSpyViewController()
        spy.handleShakeGesture()
        let editor = spy.presentedControllers.first as? ZLEditImageViewController
        let edited = TestHelper.makeImage(color: .blue)
        let presented = expectation(description: "remark screen")
        spy.onPresent = { vc in
            if vc is RemarkController { presented.fulfill() }
        }

        editor?.editFinishBlock?(edited, nil)

        wait(for: [presented], timeout: 2)
        let remarkController = spy.presentedControllers.last as? RemarkController
        XCTAssertTrue(remarkController?.selectedImage?.first === edited)
    }

    func testMotionShakeTriggersShakeHandlingWhenEnabled() {
        AppRemarkService.shared.shakeGestureEnable = true
        let spy = PresentationSpyViewController()

        spy.motionEnded(.motionShake, with: nil)

        if ShakeDetector.shared.isActive {
            XCTAssertTrue(spy.presentedControllers.isEmpty, "accelerometer detector owns shakes")
        } else {
            XCTAssertTrue(spy.presentedControllers.first is ZLEditImageViewController)
        }
    }

    func testMotionShakeIgnoredWhenDisabled() {
        AppRemarkService.shared.shakeGestureEnable = false
        let spy = PresentationSpyViewController()

        spy.motionEnded(.motionShake, with: nil)

        XCTAssertTrue(spy.presentedControllers.isEmpty)
    }

    func testMotionShakeIgnoredWhenNotConfigured() {
        AppRemarkService.shared.shakeGestureEnable = nil
        let spy = PresentationSpyViewController()

        spy.motionEnded(.motionShake, with: nil)

        XCTAssertTrue(spy.presentedControllers.isEmpty)
    }

    func testNonShakeMotionIgnored() {
        AppRemarkService.shared.shakeGestureEnable = true
        let spy = PresentationSpyViewController()

        spy.motionEnded(.none, with: nil)
        spy.motionEnded(.remoteControlPlay, with: nil)

        XCTAssertTrue(spy.presentedControllers.isEmpty)
    }

    // MARK: - Swizzling (installed by the Example app's initialize)
    func testViewDidLoadOfRemarkControllerMarksFeedbackInProgress() {
        _ = UIViewController.classInit
        let vc = TestHelper.makeRemarkController()
        vc.loadViewIfNeeded()
        XCTAssertTrue(isFeedbackInProgress)
    }

    func testViewDidLoadOfOtherControllerKeepsFeedbackState() {
        _ = UIViewController.classInit
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        XCTAssertFalse(isFeedbackInProgress)
    }

    func testClassInitIsRunOnlyOnce() {
        // a second exchange would undo the swizzle, so viewDidLoad must still be swizzled
        _ = UIViewController.classInit
        _ = UIViewController.classInit
        TestHelper.makeRemarkController().loadViewIfNeeded()
        XCTAssertTrue(isFeedbackInProgress)
    }

    // MARK: - Helpers
    private func presentRemarkScreen(screenshot: UIImage?) -> RemarkController? {
        let spy = PresentationSpyViewController()
        let presented = expectation(description: "presented")
        spy.onPresent = { _ in presented.fulfill() }

        spy.showRemarkScreen(screenshot: screenshot)

        wait(for: [presented], timeout: 2)
        return spy.presentedControllers.first as? RemarkController
    }
}

/// stub presentedViewController without a real presentation
private class PresentingStubViewController: UIViewController {
    private let stubPresented: UIViewController

    init(stubPresented: UIViewController) {
        self.stubPresented = stubPresented
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var presentedViewController: UIViewController? { stubPresented }
}
