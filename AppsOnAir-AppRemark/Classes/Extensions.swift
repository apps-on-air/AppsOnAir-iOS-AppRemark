import Foundation
import UIKit
import CoreMotion
import Toast_Swift
import AVKit
import Photos
import AppsOnAir_Core
import LWPhotoEditor

// MARK: - EXTENSION UIViewController
typealias ToastCompletionHandler = (_ success:Bool) -> Void
var isFeedbackInProgress = false


extension UIImage {
    
    ///get image Filetype
    func getFileType() -> String? {
        // Convert the UIImage to PNG data
        if self.pngData() != nil {
            return "png"
        }
        
        // Convert the UIImage to JPEG data
        if self.jpegData(compressionQuality: 1.0) != nil {
            return "jpg"
        }
        
        return nil
    }
    
    ///get Image size in Bytes
    func getImageSize() -> Data? {
        // Convert the UIImage to PNG data
        if self.pngData() != nil {
            return self.pngData()
        }
        
        // Convert the UIImage to JPEG data
        if self.jpegData(compressionQuality: 1.0) != nil {
            return self.jpegData(compressionQuality: 1.0)
        }
        
        return nil
    }
}

extension UIViewController {
    
    static let classInit: Void = {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.swizzled_viewDidLoad)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        let originalSelectorViewDidDisappear = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelectorViewDidDisappear = #selector(UIViewController.swizzled_viewDidDisappear(_:))
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelectorViewDidDisappear),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelectorViewDidDisappear) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
    }()
    
    @objc func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad()
        
        
        if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
            Logger.logInternal("\(viewControllerViewDidLoad) \(name)")
            // Check the name and perform actions accordingly
            if(name == "RemarkController" || name == "_UIImagePickerPlaceholderViewController" || name ==
            "PUPhotoPickerHostViewController" || name == "UIImagePickerController") {
             isFeedbackInProgress = true
             return
            } else {
                setupMotionDetection()
            }
        }
    }
    
    @objc private func swizzled_viewDidDisappear(_ animated: Bool) {
               if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
               
                    // Check the name and perform actions accordingly
                
                   if((name == "ZLEditImageViewController" || name == "RemarkController") && isBeingDismissed) {
                       if (name == "ZLEditImageViewController") {
                           NotificationCenter.default.post(name: NSNotification.Name("visibilityChanges"), object: nil, userInfo: ["isPresented": false])
                       }
                       isFeedbackInProgress = false
                   }
               }
        self.swizzled_viewDidDisappear(animated)
       }
    
    @objc func swizzled_dealloc() {
           // Clean up resources here if needed
           self.swizzled_dealloc()
    }
    
    func setupMotionDetection() {
        /// when shakeGestureEnable set true then Set the view controller to become the first responder for shake gesture      
            // Set the view controller to become the first responder
            _ = self.view // Ensure the view is loaded
            _ = self.becomeFirstResponder()
            
            // Add motion detection
            let motionManager = CMMotionManager()
            motionManager.startAccelerometerUpdates()
    }
    
    ///help to manage when motion is detected
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
       
        if motion == .motionShake && (AppRemarkService.shared.shakeGestureEnable ?? false) {
                Logger.logInternal(shakeGestureDetected)
                handleShakeGesture()
            }
    }
    
    func handleShakeGesture() {
        var screenshot: UIImage?
        
        guard !isFeedbackInProgress else {
            return
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("visibilityChanges"), object: nil, userInfo: ["isPresented": true])
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let captureImage = window.takeScreenshot() {
            
            isFeedbackInProgress = true
            screenshot = captureImage
        }

        ZLImageEditorConfiguration.default()
            .editImageTools([.draw, .clip, .textSticker])
        
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: screenshot ?? UIImage()) { image, Editmodel in
            NotificationCenter.default.post(name: NSNotification.Name("visibilityChanges"), object: nil, userInfo: ["isPresented": true])
            screenshot = image
            self.showRemarkScreen(screenshot: screenshot)   
        }
    }
   
    func presentScreenFromTop(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .overFullScreen // or .overCurrentContext
    
        DispatchQueue.main.async { [weak self] in
            self?.present(viewController, animated: animated, completion: completion)
        }
    }
    
    func showToast(message : String, duration: Double = 2.0,completion: ToastCompletionHandler? = nil){
        DispatchQueue.main.async {
            self.view.makeToast(message,duration: duration)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                completion?(true)
            })
        }
    }
    
    //IMAGE SELECTION  PRESENT CAMERA/PHOTO_LIBRARY
    func selectImagePopup(_ title: String? = chooseImageSource){
        let alert = UIAlertController(title: nil, message: title , preferredStyle: UIAlertController.Style.actionSheet)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view // Change this to your actual view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                popoverController.permittedArrowDirections = [] // No arrow direction
            }
        }
        
        alert.addAction(UIAlertAction(title: gallery, style: .default) { (result : UIAlertAction) -> Void in
            self.checkGalleryPermission(isAskPermission: true)
        })
        
        alert.addAction(UIAlertAction(title: cancel, style: .destructive) { (result : UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func checkGalleryPermission(isAskPermission: Bool = false){
        if(isAskPermission){
            if ((Bundle.main.photoPermission ?? false)) {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .denied {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: remark , message: errorGalleryPermission, preferredStyle: UIAlertController.Style.alert);
                            
                            alert.addAction(UIAlertAction(title: ok, style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            DispatchQueue.main.async {
                                let imagePicker = UIImagePickerController()
                                imagePicker.delegate = (self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                                imagePicker.sourceType = .photoLibrary
                                
                                imagePicker.allowsEditing = false
                                imagePicker.modalPresentationStyle = .fullScreen
                                self.present(imagePicker, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
        if !(Bundle.main.photoPermission ?? false) {
#if DEBUG
            // In DEBUG mode - show toast
            if let topVC = UIApplication.topViewController() {
                topVC.showToast(message:errorPhotosPermission)
            }
            Logger.logInfo(errorPhotosPermission,prefix: appsOnAirRemark)
#else
            // In RELEASE mode
            Logger.logInfo(errorPhotosPermission,prefix: appsOnAirRemark)
#endif
        }
    }
    
    public func showRemarkScreen(screenshot: UIImage? = nil) {
        // initialize UI StoryBoard
        
        let bundleURL = Bundle(for: RemarkController.self).url(forResource: "AppsOnAir-AppRemark", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL ?? URL(fileURLWithPath: ""))
        let storyboard = UIStoryboard(name: "AppRemark", bundle: bundle)
        let Vc = storyboard.instantiateViewController(withIdentifier: "RemarkController") as? RemarkController
        
        if(screenshot != nil) {
            Vc?.selectedImage = [screenshot ?? UIImage()]
        }
        // initialize the remark class
        let appRemarkServices = AppRemarkService.shared

        // help to set variables 
        Vc?.appBarBackgroundColor = appRemarkServices.appBarBackgroundColor
        Vc?.appBarTitleText = appRemarkServices.appBarTitleText
        Vc?.appBarTitleColor = appRemarkServices.appBarTitleColor
        
        Vc?.lblTicketText = appRemarkServices.remarkTypeLabelText
        
        Vc?.labelColor = appRemarkServices.labelColor
        Vc?.hintColor = appRemarkServices.hintColor
        Vc?.pageBackgroundColor = appRemarkServices.pageBackgroundColor
        
        Vc?.inputTextColor = appRemarkServices.inputTextColor
        Vc?.hintColor = appRemarkServices.hintColor
        
        Vc?.descriptionLabelText = appRemarkServices.descriptionLabelText 
        let defaultLimit = 255
        if let limit = appRemarkServices.descriptionMaxLength, limit > 0 {
            Vc?.txtDescriptionCharLimit = limit
        } else {
            Vc?.txtDescriptionCharLimit = defaultLimit
        }
        Vc?.txtDescriptionHintText = appRemarkServices.descriptionHintText
        
        Vc?.buttonText = appRemarkServices.buttonText
        Vc?.buttonTextColor = appRemarkServices.buttonTextColor
        Vc?.buttonBackgroundColor = appRemarkServices.buttonBackgroundColor
        
        // present screen of remark
        self.presentScreenFromTop(Vc ?? UIViewController())
    }
}

// MARK: - EXTENSION UIView
extension UIView {
    /*===================================================
     * function Purpose: CAPTURE SNAPSHOT OF SCREEN
     ===================================================*/
    ///capture screen snapshot
    func takeScreenshot() -> UIImage? {
        // Get the screen bounds including the status bar
        let screenBounds = UIScreen.main.bounds
        
        // Begin image context
        UIGraphicsBeginImageContextWithOptions(screenBounds.size, false, UIScreen.main.scale)

        // Use UIWindowScene to access windows (iOS 15+)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.drawHierarchy(in: screenBounds, afterScreenUpdates: true)
            }
        }
        
        // Get the captured image
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        // End image context
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    /*===================================================
     * function Purpose: ADD BOTTOM SHADOW TO VIEW
     ===================================================*/
    ///set shadow in bottom of view
    func addShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,y: bounds.maxY - layer.shadowRadius,
                                                         width: screenWidth,
                                                         height: layer.shadowRadius)).cgPath
    }
    
    // OLD
     func addShadows(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0,
                   cornerRadiusIs:CGFloat = 0.0) {
        
            layer.cornerRadius = cornerRadiusIs
            layer.shadowColor = shadowColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        
    }
    
    func addCornerRadius(color: UIColor = UIColor.lightGray, raduis: CGFloat?) {
        self.layer.cornerRadius = raduis ?? 8.0
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true 
        self.layer.borderColor = color.cgColor
    }
    
    /*===================================================
     * function Purpose: ROUND CORNERS ON SPECIFIC SIDES
     ===================================================*/
    ///set round corners on specific side
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }

}

// MARK: - EXTENSION UIDevice
extension UIDevice {
    
        var modelIdentifier: String {
            #if targetEnvironment(simulator)
            if let simDeviceName = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return "Simulator (\(simDeviceName))"
            } else {
                return "Simulator"
            }
            #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
            #endif
        }
    
}

// MARK: - EXTENSION UIApplication
extension UIApplication {
    
    var activeWindow: UIWindow? {
            return connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.activeWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
