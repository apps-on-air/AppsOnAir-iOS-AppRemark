import Foundation
import IQKeyboardToolbarManager
import UIKit
import AVFoundation
import AppsOnAir_Core

public class AppRemarkService:NSObject {
    //MARK: - Declarations
    @objc public static let shared = AppRemarkService()
    let appsOnAirCore = AppsOnAirCoreServices()
    
    private var appId: String = ""
    private var window: UIWindow?
    
    /// set navigationBar color (hex value eg: 000000)
    var appBarBackgroundColor: String?
    
    /// set navigationBar title text
    var appBarTitleText: String?
    
    /// set navigationBar title color (hex value eg: 000000)
    var appBarTitleColor: String?
    
    /// Set background color (hex value eg: 000000)
    var pageBackgroundColor: String?
    
    /// set labelTicket text
    var remarkTypeLabelText: String?
    
    /// set labelTicket text color
    var labelColor: String?
    
    /// set inputFields hint text color
    var inputTextColor: String?
    
    /// set inputFields hint text color
    var hintColor: String?
    
    /// set description field char limit (default 255)
    var descriptionMaxLength: Int?
    
    /// set description hint text
    var descriptionLabelText: String?
    
    /// set description hint text
    var descriptionHintText: String?
    
    /// set btnSubmit text
    var buttonText: String?
    
    /// set btnSubmit text color
    var buttonTextColor: String?
    
    /// set btnSubmit background color
    var buttonBackgroundColor: String?
    
    /// set Additional params while init
    var additionalParams: [String:String]?
    
    /// set Shake gesture
    var shakeGestureEnable: Bool?
    
    //MARK: - Methods
        
    /// setup remark screen with options for customize and shakeGestureEnable is for enable shake Gesture , default it is true
    @objc public func initialize(shakeGestureEnable:Bool = true,options: NSDictionary = [:]) {
        
        // Help to initialize the core services of AppsOnAir
        appsOnAirCore.initialize()
        self.appId = appsOnAirCore.appId

        // Help to customized the theme
        let customizeOptions = options.reduce(into: NSMutableDictionary()) { result, pair in
            if let stringKey = pair.key as? String {
                result[stringKey.lowercased()] = pair.value
            }
        }
        
        self.appBarBackgroundColor = customizeOptions["appbarbackgroundcolor"] as? String
        self.appBarTitleText = customizeOptions["appbartitletext"] as? String
        self.appBarTitleColor = customizeOptions["appbartitlecolor"] as? String
        
        self.pageBackgroundColor = customizeOptions["pagebackgroundcolor"] as? String
        
        self.remarkTypeLabelText = customizeOptions["remarktypelabeltext"] as? String
        self.labelColor = customizeOptions["labelcolor"] as? String
        
        self.hintColor = customizeOptions["hintcolor"] as? String
        
        self.descriptionLabelText = customizeOptions["descriptionlabeltext"] as? String
        self.descriptionMaxLength = customizeOptions["descriptionmaxlength"] as? Int
        self.descriptionHintText = customizeOptions["descriptionhinttext"] as? String
        
        self.inputTextColor = customizeOptions["inputtextcolor"] as? String
        self.buttonText = customizeOptions["buttontext"] as? String
        self.buttonTextColor = customizeOptions["buttontextcolor"] as? String
        self.buttonBackgroundColor = customizeOptions["buttonbackgroundcolor"] as? String

        // Init the Shake motion feature
        self.shakeGestureEnable = shakeGestureEnable
        
        // set once remark screen open
        if(self.shakeGestureEnable ?? false){
            _ = UIViewController.classInit
        }
        
        // To enable for managing distance between keyboard and textField.
        DispatchQueue.main.async {
            IQKeyboardToolbarManager.shared.isEnabled = true
        }
    }
    
    
    /// help to add additional params  of app and open the manually remark screen
    @objc public func addRemark(extraPayload: NSDictionary = [:]) {
        
        self.additionalParams = extraPayload as? [String : String] ?? nil
        
        //Help to open the remark screen
        self.openRemarkScreen()
    }
    
    
    private func openRemarkScreen() {
        if let topViewController = UIApplication.topViewController(){
            NotificationCenter.default.post(name: NSNotification.Name("visibilityChanges"), object: nil, userInfo: ["isPresented": true])
            topViewController.showRemarkScreen()
        }
    }
}
