import XCTest
import UIKit
import Combine
@testable import AppsOnAir_AppRemark

class RemarkControllerTests: XCTestCase {

    private var controller: RemarkController!
    private var cancellables = Set<AnyCancellable>()
    private var originalFeedbackInProgress = false
    private var originalAppId = ""
    private var originalNetworkConnected: Bool?
    private var snapshot: ServiceSnapshot!

    override func setUp() {
        super.setUp()
        originalFeedbackInProgress = isFeedbackInProgress
        originalAppId = AppRemarkService.shared.appsOnAirCore.appId
        originalNetworkConnected = AppRemarkService.shared.appsOnAirCore.isNetworkConnected
        snapshot = ServiceSnapshot(AppRemarkService.shared)
        controller = TestHelper.makeRemarkController()
    }

    override func tearDown() {
        MockURLProtocol.unregister()
        cancellables.removeAll()
        controller = nil
        isFeedbackInProgress = originalFeedbackInProgress
        AppRemarkService.shared.appsOnAirCore.appId = originalAppId
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = originalNetworkConnected
        snapshot.restore(AppRemarkService.shared)
        super.tearDown()
    }

    // MARK: - Storyboard
    func testStoryboardInstantiatesControllerWithOutlets() {
        controller.loadViewIfNeeded()

        XCTAssertNotNil(controller.navView)
        XCTAssertNotNil(controller.statusView)
        XCTAssertNotNil(controller.navTitle)
        XCTAssertNotNil(controller.btnNavClose)
        XCTAssertNotNil(controller.lblTicketType)
        XCTAssertNotNil(controller.dropDownTitle)
        XCTAssertNotNil(controller.dropDown)
        XCTAssertNotNil(controller.lblDescription)
        XCTAssertNotNil(controller.txtDescription)
        XCTAssertNotNil(controller.descriptionCharLimit)
        XCTAssertNotNil(controller.lblAppsOnAir)
        XCTAssertNotNil(controller.clView)
        XCTAssertNotNil(controller.clViewHeight)
        XCTAssertNotNil(controller.btnSubmit)
    }

    // MARK: - Default appearance
    func testDefaultTexts() {
        controller.loadViewIfNeeded()

        XCTAssertEqual(controller.navTitle.text, "Add Remark")
        XCTAssertEqual(controller.dropDownTitle.text, "Remark Type")
        XCTAssertEqual(controller.lblDescription.text, "Description")
        XCTAssertEqual(controller.descriptionCharLimit.text, "0/255")
        XCTAssertEqual(controller.txtDescription.text, "Add description here..")
        XCTAssertEqual(controller.btnSubmit.title(for: .normal), "Submit")
        XCTAssertEqual(controller.lblAppsOnAir.text, "We run on AppsOnAir")
        XCTAssertEqual(controller.btnNavClose.title(for: .normal), "")
    }

    func testDefaultColors() {
        controller.loadViewIfNeeded()

        TestHelper.assertSameColor(controller.view.backgroundColor, sColorPrimaryThemeLight)
        TestHelper.assertSameColor(controller.navView.backgroundColor, sColorPrimaryThemeLight)
        TestHelper.assertSameColor(controller.statusView.backgroundColor, sColorPrimaryThemeLight)
        TestHelper.assertSameColor(controller.navTitle.textColor, sColorTextBlack)
        TestHelper.assertSameColor(controller.lblTicketType.textColor, sColorTextLightGray)
        TestHelper.assertSameColor(controller.lblDescription.textColor, sColorTextLightGray)
        TestHelper.assertSameColor(controller.descriptionCharLimit.textColor, sColorTextBlack)
        TestHelper.assertSameColor(controller.btnSubmit.backgroundColor, sColorPrimaryThemeDark)
        TestHelper.assertSameColor(controller.btnSubmit.titleColor(for: .normal), sColorTextWhite)
        TestHelper.assertSameColor(controller.lblAppsOnAir.textColor, sColorTextPrimary)
        let hintColor = controller.txtDescription.attributedText.attribute(
            .foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        TestHelper.assertSameColor(hintColor, sColorTextLightGray)
    }

    func testDropDownDefaults() {
        controller.loadViewIfNeeded()

        XCTAssertEqual(controller.ticketType, ["Improvement suggestion", "Bug report"])
        XCTAssertEqual(controller.dropDown.text, "Improvement suggestion")
        XCTAssertEqual(controller.dropDown.optionArray, controller.ticketType)
        XCTAssertEqual(controller.dropDown.selectedIndex, 0)
        XCTAssertFalse(controller.dropDown.isSearchEnable)
        XCTAssertEqual(controller.dropDown.arrowSize, 12)
        XCTAssertFalse(controller.dropDown.checkMarkEnabled)
        XCTAssertFalse(controller.dropDown.handleKeyboard)
    }

    func testLoaderHiddenAfterLoad() {
        controller.loadViewIfNeeded()

        XCTAssertTrue(controller.overlayView.isHidden)
        XCTAssertFalse(controller.activityIndicator.isAnimating)
        XCTAssertTrue(controller.overlayView.superview === controller.view)
        XCTAssertTrue(controller.activityIndicator.superview === controller.overlayView)
    }

    func testControlsHaveTargets() {
        controller.loadViewIfNeeded()

        XCTAssertEqual(
            controller.btnNavClose.actions(forTarget: controller, forControlEvent: .touchUpInside),
            ["btnClose:"])
        XCTAssertEqual(
            controller.btnSubmit.actions(forTarget: controller, forControlEvent: .touchUpInside),
            ["btnSubmit:"])
    }

    func testCollectionViewSetup() {
        controller.loadViewIfNeeded()

        XCTAssertTrue(controller.clView.delegate === controller)
        XCTAssertTrue(controller.clView.dataSource === controller)
        let layout = controller.clView.collectionViewLayout as? UICollectionViewFlowLayout
        XCTAssertEqual(layout?.scrollDirection, .horizontal)
        XCTAssertEqual(layout?.sectionInset, UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        XCTAssertEqual(controller.clViewHeight.constant, screenHeight * 0.024)
        XCTAssertTrue(controller.txtDescription.delegate === controller)
    }

    // MARK: - Customized appearance
    func testCustomTexts() {
        controller.appBarTitleText = "Feedback"
        controller.lblTicketText = "Kind"
        controller.descriptionLabelText = "Details"
        controller.txtDescriptionHintText = "Tell us more"
        controller.txtDescriptionCharLimit = 100
        controller.buttonText = "Send"
        controller.loadViewIfNeeded()

        XCTAssertEqual(controller.navTitle.text, "Feedback")
        XCTAssertEqual(controller.dropDownTitle.text, "Kind")
        XCTAssertEqual(controller.lblDescription.text, "Details")
        XCTAssertEqual(controller.txtDescription.text, "Tell us more")
        XCTAssertEqual(controller.descriptionCharLimit.text, "0/100")
        XCTAssertEqual(controller.btnSubmit.title(for: .normal), "Send")
    }

    func testCustomColors() {
        controller.pageBackgroundColor = "#FF0000"
        controller.appBarBackgroundColor = "#00FF00"
        controller.appBarTitleColor = "#0000FF"
        controller.labelColor = "#111111"
        controller.hintColor = "#222222"
        controller.buttonBackgroundColor = "#333333"
        controller.buttonTextColor = "#444444"
        controller.loadViewIfNeeded()

        TestHelper.assertColor(controller.view.backgroundColor, red: 1, green: 0, blue: 0)
        TestHelper.assertColor(controller.navView.backgroundColor, red: 0, green: 1, blue: 0)
        TestHelper.assertColor(controller.statusView.backgroundColor, red: 0, green: 1, blue: 0)
        TestHelper.assertColor(controller.navTitle.textColor, red: 0, green: 0, blue: 1)
        let label: CGFloat = 0x11 / 255
        TestHelper.assertColor(controller.lblTicketType.textColor, red: label, green: label, blue: label)
        TestHelper.assertColor(controller.lblDescription.textColor, red: label, green: label, blue: label)
        TestHelper.assertColor(controller.descriptionCharLimit.textColor, red: label, green: label, blue: label)
        let hint = controller.txtDescription.attributedText.attribute(
            .foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        TestHelper.assertColor(hint, red: 0x22 / 255, green: 0x22 / 255, blue: 0x22 / 255)
        TestHelper.assertColor(controller.btnSubmit.backgroundColor, red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
        TestHelper.assertColor(
            controller.btnSubmit.titleColor(for: .normal), red: 0x44 / 255, green: 0x44 / 255, blue: 0x44 / 255)
    }

    func testInvalidColorsFallBackToDefaults() {
        controller.pageBackgroundColor = "not a color"
        controller.appBarBackgroundColor = "#12"
        controller.buttonBackgroundColor = ""
        controller.loadViewIfNeeded()

        TestHelper.assertSameColor(controller.view.backgroundColor, sColorPrimaryThemeLight)
        TestHelper.assertSameColor(controller.navView.backgroundColor, sColorPrimaryThemeLight)
        TestHelper.assertSameColor(controller.btnSubmit.backgroundColor, sColorPrimaryThemeDark)
    }

    // MARK: - Loader
    func testShowAndHideLoader() {
        controller.loadViewIfNeeded()

        controller.showLoader()
        XCTAssertFalse(controller.overlayView.isHidden)
        XCTAssertTrue(controller.activityIndicator.isAnimating)

        controller.hideLoader()
        XCTAssertTrue(controller.overlayView.isHidden)
        XCTAssertFalse(controller.activityIndicator.isAnimating)
    }

    func testFailureToastHidesLoader() {
        controller.loadViewIfNeeded()
        controller.showLoader()

        controller.failureToast()

        waitForLoaderHidden()
    }

    func testNetworkFailureToastHidesLoader() {
        controller.loadViewIfNeeded()
        controller.showLoader()

        controller.failureToast(isNetworkError: true)

        waitForLoaderHidden()
    }

    // MARK: - Dismiss
    func testDismissControllerPostsVisibilityChange() {
        controller.loadViewIfNeeded()
        let notified = expectation(forNotification: NSNotification.Name("visibilityChanges"), object: nil) {
            $0.userInfo?["isPresented"] as? Bool == false
        }

        controller.dismissController()

        wait(for: [notified], timeout: 1)
    }

    func testCloseButtonDismisses() {
        controller.loadViewIfNeeded()
        let notified = expectation(forNotification: NSNotification.Name("visibilityChanges"), object: nil)

        controller.btnClose(controller.btnNavClose)

        wait(for: [notified], timeout: 1)
    }

    // MARK: - Collection view
    func testNumberOfItemsShowsAddCellUntilTwoImages() {
        controller.loadViewIfNeeded()
        let expected = [0: 1, 1: 2, 2: 2, 3: 3]

        expected.forEach { imageCount, items in
            controller.selectedImage = Array(repeating: TestHelper.makeImage(), count: imageCount)
            XCTAssertEqual(
                controller.collectionView(controller.clView, numberOfItemsInSection: 0), items,
                "\(imageCount) images")
        }
    }

    func testNumberOfItemsWithNilImages() {
        controller.loadViewIfNeeded()
        controller.selectedImage = nil

        XCTAssertEqual(controller.collectionView(controller.clView, numberOfItemsInSection: 0), 1)
    }

    func testCellsForImagesAndAddButton() {
        let image = TestHelper.makeImage()
        controller.selectedImage = [image]
        controller.loadViewIfNeeded()

        let imageCell = controller.collectionView(controller.clView, cellForItemAt: IndexPath(row: 0, section: 0))
        let addCell = controller.collectionView(controller.clView, cellForItemAt: IndexPath(row: 1, section: 0))

        let cell = imageCell as? ImageViewCell
        XCTAssertNotNil(cell)
        XCTAssertTrue(cell?.imageView.image === image)
        XCTAssertEqual(cell?.imageView.contentMode, .scaleAspectFit)
        XCTAssertEqual(cell?.btnRemove.tag, 0)
        XCTAssertEqual(cell?.btnRemove.title(for: .normal), "")
        XCTAssertEqual(cell?.bgImageView.layer.cornerRadius, 6)
        XCTAssertEqual(
            cell?.btnRemove.actions(forTarget: controller, forControlEvent: .touchUpInside), ["removeSnapshot:"])
        XCTAssertTrue(addCell is AddImageCVCell)
        XCTAssertEqual((addCell as? AddImageCVCell)?.imageView.contentMode, .scaleAspectFill)
    }

    func testItemSize() {
        controller.loadViewIfNeeded()

        let size = controller.collectionView(
            controller.clView, layout: controller.clView.collectionViewLayout,
            sizeForItemAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(size.width, (screenWidth - 16) / 3, accuracy: 0.001)
        XCTAssertEqual(size.height, screenHeight * 0.25, accuracy: 0.001)
    }

    func testRemoveSnapshotRemovesImageAtTag() {
        let first = TestHelper.makeImage(color: .red)
        let second = TestHelper.makeImage(color: .blue)
        controller.selectedImage = [first, second]
        controller.loadViewIfNeeded()
        let button = UIButton()
        button.tag = 0

        controller.removeSnapshot(button)

        XCTAssertEqual(controller.selectedImage?.count, 1)
        XCTAssertTrue(controller.selectedImage?.first === second)
    }

    func testSelectingAddCellOpensImagePopup() {
        let spy = PresentingRemarkController.make()
        spy.loadViewIfNeeded()

        spy.collectionView(spy.clView, didSelectItemAt: IndexPath(row: 0, section: 0))

        XCTAssertTrue(spy.presented.first is UIAlertController)
    }

    func testSelectingImageCellDoesNothing() {
        let spy = PresentingRemarkController.make()
        spy.selectedImage = [TestHelper.makeImage()]
        spy.loadViewIfNeeded()

        spy.collectionView(spy.clView, didSelectItemAt: IndexPath(row: 0, section: 0))

        XCTAssertTrue(spy.presented.isEmpty)
    }

    // MARK: - Text view
    func testBeginEditingClearsHint() {
        controller.inputTextColor = "#FF0000"
        controller.loadViewIfNeeded()

        controller.textViewDidBeginEditing(controller.txtDescription)

        XCTAssertEqual(controller.txtDescription.text, "")
        TestHelper.assertColor(controller.txtDescription.textColor, red: 1, green: 0, blue: 0)
    }

    func testBeginEditingClearsCustomHint() {
        controller.txtDescriptionHintText = "Custom hint"
        controller.loadViewIfNeeded()

        controller.textViewDidBeginEditing(controller.txtDescription)

        XCTAssertEqual(controller.txtDescription.text, "")
        TestHelper.assertSameColor(controller.txtDescription.textColor, sColorTextBlack)
    }

    func testBeginEditingKeepsUserText() {
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "My text"

        controller.textViewDidBeginEditing(controller.txtDescription)

        XCTAssertEqual(controller.txtDescription.text, "My text")
    }

    func testEndEditingRestoresHintWhenEmpty() {
        controller.hintColor = "#00FF00"
        controller.loadViewIfNeeded()
        controller.txtDescription.text = ""

        controller.textViewDidEndEditing(controller.txtDescription)

        XCTAssertEqual(controller.txtDescription.text, "Add description here..")
        TestHelper.assertColor(controller.txtDescription.textColor, red: 0, green: 1, blue: 0)
    }

    func testEndEditingKeepsUserText() {
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "Typed"

        controller.textViewDidEndEditing(controller.txtDescription)

        XCTAssertEqual(controller.txtDescription.text, "Typed")
    }

    func testTypingUpdatesCharacterCount() {
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "abc"

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 3, length: 0),
            replacementText: "d")

        XCTAssertTrue(allowed)
        XCTAssertEqual(controller.descriptionCharLimit.text, "4/255")
    }

    func testTypingUpToLimitIsAllowed() {
        controller.txtDescriptionCharLimit = 5
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "abcd"

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 4, length: 0),
            replacementText: "e")

        XCTAssertTrue(allowed)
        XCTAssertEqual(controller.descriptionCharLimit.text, "5/5")
    }

    func testTypingBeyondLimitIsRejected() {
        controller.txtDescriptionCharLimit = 5
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "abcde"
        controller.descriptionCharLimit.text = "5/5"

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 5, length: 0),
            replacementText: "f")

        XCTAssertFalse(allowed)
        XCTAssertEqual(controller.descriptionCharLimit.text, "5/5")
    }

    func testPastingBeyondLimitIsRejected() {
        controller.txtDescriptionCharLimit = 5
        controller.loadViewIfNeeded()
        controller.txtDescription.text = ""

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 0, length: 0),
            replacementText: "123456")

        XCTAssertFalse(allowed)
    }

    func testDeletingUpdatesCharacterCount() {
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "abc"

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 2, length: 1),
            replacementText: "")

        XCTAssertTrue(allowed)
        XCTAssertEqual(controller.descriptionCharLimit.text, "2/255")
    }

    func testReplacingSelectionCountsResultingText() {
        controller.txtDescriptionCharLimit = 3
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "abc"

        let allowed = controller.textView(
            controller.txtDescription, shouldChangeTextIn: NSRange(location: 0, length: 3),
            replacementText: "xyz")

        XCTAssertTrue(allowed)
        XCTAssertEqual(controller.descriptionCharLimit.text, "3/3")
    }

    // MARK: - Image picker
    func testPickingImageAppendsIt() {
        controller.loadViewIfNeeded()
        let image = TestHelper.makeImage()

        controller.imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: [.originalImage: image])

        XCTAssertEqual(controller.selectedImage?.count, 1)
        XCTAssertTrue(controller.selectedImage?.first === image)
        XCTAssertEqual(controller.collectionView(controller.clView, numberOfItemsInSection: 0), 2)
    }

    func testPickingImageDismissesPicker() {
        controller.loadViewIfNeeded()
        let picker = DismissSpyImagePicker()

        controller.imagePickerController(picker, didFinishPickingMediaWithInfo: [.originalImage: TestHelper.makeImage()])

        XCTAssertTrue(picker.didDismiss)
    }

    func testCancelPickerDismissesIt() {
        controller.loadViewIfNeeded()
        let picker = DismissSpyImagePicker()

        controller.imagePickerControllerDidCancel(picker)

        XCTAssertTrue(picker.didDismiss)
        XCTAssertEqual(controller.selectedImage?.count, 0)
    }

    // MARK: - Submit validation
    func testSubmitWithoutAppIdShowsFailure() {
        MockURLProtocol.register()
        AppRemarkService.shared.appsOnAirCore.appId = ""
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = true
        controller.loadViewIfNeeded()

        controller.btnSubmit(controller.btnSubmit)

        XCTAssertFalse(controller.overlayView.isHidden, "loader is shown while submitting")
        waitForLoaderHidden()
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    func testSubmitWithoutNetworkShowsFailure() {
        MockURLProtocol.register()
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = false
        controller.loadViewIfNeeded()

        controller.btnSubmit(controller.btnSubmit)

        waitForLoaderHidden()
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    func testSubmitWithUnknownNetworkStateShowsFailure() {
        MockURLProtocol.register()
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = nil
        controller.loadViewIfNeeded()

        controller.btnSubmit(controller.btnSubmit)

        waitForLoaderHidden()
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    // MARK: - Submit flow
    func testSubmitSuggestionWithoutImagesSendsFeedback() {
        stubServer(feedback: ["status": "SUCCESS", "message": "Thanks for the feedback"])
        AppRemarkService.shared.additionalParams = ["userId": "USER_ID"]
        controller.loadViewIfNeeded()
        controller.txtDescription.text = "  The app is great  "

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "SUCCESS")
        XCTAssertEqual(response?["message"] as? String, "Thanks for the feedback")
        XCTAssertTrue(MockURLProtocol.requests(matching: "/signed-url").isEmpty)

        let body = feedbackBody()
        XCTAssertEqual((body?["where"] as? [String: Any])?["appId"] as? String, originalAppId)
        let data = body?["data"] as? [String: Any]
        XCTAssertEqual(data?["description"] as? String, "The app is great")
        XCTAssertEqual(data?["type"] as? String, "SUGGESTION")
        XCTAssertEqual((data?["attachments"] as? [Any])?.count, 0)
        XCTAssertEqual((data?["additionalMetadata"] as? [String: Any])?["userId"] as? String, "USER_ID")
        XCTAssertNotNil(data?["deviceInfo"] as? [String: Any])
        XCTAssertTrue(controller.overlayView.isHidden)
    }

    func testSubmitSendsDeviceInfo() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.loadViewIfNeeded()

        _ = submitAndWaitForResponse()

        let deviceInfo = (feedbackBody()?["data"] as? [String: Any])?["deviceInfo"] as? [String: Any]
        XCTAssertEqual(deviceInfo?["locale"] as? String, AdditionalDeviceInfo.fetchLocaleDetails())
        XCTAssertEqual(deviceInfo?["installVendor"] as? String, AdditionalDeviceInfo.fetchInstallVendor())
        XCTAssertEqual(deviceInfo?["externalReferenceId"] as? String, AdditionalDeviceInfo.fetchDeviceIdentifier())
        XCTAssertEqual(deviceInfo?["themeMode"] as? String, AdditionalDeviceInfo.fetchThemeMode())
        XCTAssertNotNil(deviceInfo?["fontScale"])
        XCTAssertNotNil(deviceInfo?["biometricInfo"] as? [String: Any])
        XCTAssertNotNil(deviceInfo?["app_permissions"])
    }

    func testSubmitBugReportType() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.loadViewIfNeeded()
        controller.dropDown.text = controller.ticketType[1]

        _ = submitAndWaitForResponse()

        XCTAssertEqual((feedbackBody()?["data"] as? [String: Any])?["type"] as? String, "BUG")
    }

    func testSubmitWithHintTextSendsEmptyDescription() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.loadViewIfNeeded()

        _ = submitAndWaitForResponse()

        XCTAssertEqual((feedbackBody()?["data"] as? [String: Any])?["description"] as? String, "")
    }

    func testSubmitWithCustomHintTextSendsEmptyDescription() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.txtDescriptionHintText = "Custom hint"
        controller.loadViewIfNeeded()

        _ = submitAndWaitForResponse()

        XCTAssertEqual((feedbackBody()?["data"] as? [String: Any])?["description"] as? String, "")
    }

    func testSubmitWithWhitespaceDescriptionSendsEmptyDescription() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.loadViewIfNeeded()
        controller.txtDescription.text = " \n\t "

        _ = submitAndWaitForResponse()

        XCTAssertEqual((feedbackBody()?["data"] as? [String: Any])?["description"] as? String, "")
    }

    func testSubmitWithoutAdditionalMetadataSendsEmptyObject() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        AppRemarkService.shared.additionalParams = nil
        controller.loadViewIfNeeded()

        _ = submitAndWaitForResponse()

        let metadata = (feedbackBody()?["data"] as? [String: Any])?["additionalMetadata"] as? [String: Any]
        XCTAssertEqual(metadata?.isEmpty, true)
    }

    func testSubmitWithImagesUploadsThemAndSendsAttachments() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK"])
        controller.selectedImage = [TestHelper.makeImage(color: .red), TestHelper.makeImage(color: .green)]
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "SUCCESS")
        let signInRequests = MockURLProtocol.requests(matching: "/signed-url")
        XCTAssertEqual(signInRequests.count, 2)
        let signInData = TestHelper.jsonObject(from: signInRequests.first?.httpBody)?["data"] as? [String: Any]
        XCTAssertEqual(signInData?["fileType"] as? String, "image/png")
        XCTAssertEqual(signInData?["appId"] as? String, originalAppId)
        XCTAssertTrue((signInData?["fileName"] as? String)?.hasPrefix("AppsOnAir-AppRemark_Example_") ?? false)
        XCTAssertGreaterThan(signInData?["fileSize"] as? Double ?? 0, 0)
        XCTAssertEqual(MockURLProtocol.requests(matching: "/upload").count, 2)

        let attachments = (feedbackBody()?["data"] as? [String: Any])?["attachments"] as? [[String: Any]]
        XCTAssertEqual(attachments?.count, 2)
        XCTAssertEqual(attachments?.first?["key"] as? String, "uploads/file.png")
        XCTAssertEqual(attachments?.first?["fileType"] as? String, "image/png")
        XCTAssertEqual(attachments?.first?["size"] as? String, "0.00")
    }

    func testSubmitServerFailureReportsFailure() {
        stubServer(feedback: ["status": "FAILURE", "message": "Invalid app"])
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, "Invalid app")
        waitForLoaderHidden()
    }

    func testSubmitErrorFieldReportsFailureEvenWithSuccessStatus() {
        stubServer(feedback: ["status": "SUCCESS", "message": "OK", "error": "Oops"])
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
    }

    func testSubmitEmptyMessageReportsFailure() {
        stubServer(feedback: ["status": "SUCCESS", "message": "   "])
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, "")
    }

    func testSubmitMissingMessageReportsGenericFailure() {
        stubServer(feedback: ["status": "FAILURE"])
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, errorSomethingWentWrong)
    }

    func testSubmitInvalidServerResponseReportsGenericFailure() {
        MockURLProtocol.register()
        MockURLProtocol.handler = { _ in .init(statusCode: 500, data: Data("oops".utf8)) }
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = true
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, errorSomethingWentWrong)
    }

    func testSubmitSignInFailureReportsServerMessage() {
        stubServer(
            signIn: ["status": "FAILURE", "message": "Upload limit reached"],
            feedback: ["status": "SUCCESS", "message": "OK"])
        controller.selectedImage = [TestHelper.makeImage()]
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, "Upload limit reached")
        XCTAssertTrue(MockURLProtocol.requests(matching: "/feedback").isEmpty, "feedback is not sent")
    }

    func testSubmitSignInWithoutURLsReportsGenericFailure() {
        stubServer(signIn: ["status": "SUCCESS", "data": [:]], feedback: ["status": "SUCCESS", "message": "OK"])
        controller.selectedImage = [TestHelper.makeImage()]
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, errorSomethingWentWrong)
    }

    func testSubmitUploadFailureReportsFailure() {
        stubServer(uploadStatus: 403, feedback: ["status": "SUCCESS", "message": "OK"])
        controller.selectedImage = [TestHelper.makeImage()]
        controller.loadViewIfNeeded()

        let response = submitAndWaitForResponse()

        XCTAssertEqual(response?["status"] as? String, "FAILURE")
        XCTAssertEqual(response?["message"] as? String, errorSomethingWentWrong)
        XCTAssertTrue(MockURLProtocol.requests(matching: "/feedback").isEmpty)
    }

    // MARK: - Helpers
    private func waitForLoaderHidden(file: StaticString = #filePath, line: UInt = #line) {
        let hidden = expectation(
            for: NSPredicate { [weak controller] _, _ in controller?.overlayView.isHidden ?? true },
            evaluatedWith: nil)
        wait(for: [hidden], timeout: 5)
    }

    private func stubServer(
        signIn: [String: Any]? = nil, uploadStatus: Int = 200, feedback: [String: Any]
    ) {
        MockURLProtocol.register()
        AppRemarkService.shared.appsOnAirCore.isNetworkConnected = true
        let signInResponse =
            signIn ?? [
                "status": "SUCCESS",
                "data": [
                    "signedURL": "https://bucket.test/upload?X-Goog-Signature=abc",
                    "fileUrl": "uploads/file.png",
                ],
            ]
        MockURLProtocol.handler = { request in
            switch request.url?.path {
            case "/signed-url": return .init(data: MockURLProtocol.jsonData(signInResponse))
            case "/upload": return .init(statusCode: uploadStatus)
            case "/feedback": return .init(data: MockURLProtocol.jsonData(feedback))
            default: return .init(error: URLError(.unsupportedURL))
            }
        }
    }

    /// tap submit and wait for the response published to the SDK listener
    private func submitAndWaitForResponse() -> [String: Any]? {
        var response: [String: Any]?
        let published = expectation(description: "remark response")
        AppRemarkService.shared.$remarkResponse
            .dropFirst()
            .first()
            .sink { value in
                response = value
                published.fulfill()
            }
            .store(in: &cancellables)

        controller.btnSubmit(controller.btnSubmit)

        wait(for: [published], timeout: 20)
        return response
    }

    private func feedbackBody() -> [String: Any]? {
        return TestHelper.jsonObject(from: MockURLProtocol.requests(matching: "/feedback").last?.httpBody)
    }
}

/// RemarkController that captures presentations, the class is swapped on a storyboard instance
/// so it must not add stored properties
private class PresentingRemarkController: RemarkController {
    private static var presentedByController: [ObjectIdentifier: [UIViewController]] = [:]

    var presented: [UIViewController] {
        Self.presentedByController[ObjectIdentifier(self)] ?? []
    }

    static func make() -> PresentingRemarkController {
        let controller = TestHelper.makeRemarkController()
        object_setClass(controller, PresentingRemarkController.self)
        return controller as! PresentingRemarkController
    }

    override func present(
        _ viewControllerToPresent: UIViewController, animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        Self.presentedByController[ObjectIdentifier(self), default: []].append(viewControllerToPresent)
    }
}

private class DismissSpyImagePicker: UIImagePickerController {
    var didDismiss = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didDismiss = true
    }
}
