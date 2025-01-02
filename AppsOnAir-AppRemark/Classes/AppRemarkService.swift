import Foundation
import UIKit
import AVFoundation
import IQKeyboardManagerSwift
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
        self.appBarBackgroundColor = options["appBarBackgroundColor"] as? String
        self.appBarTitleText = options["appBarTitleText"] as? String  
        self.appBarTitleColor = options["appBarTitleColor"] as? String
        
        self.pageBackgroundColor = options["pageBackgroundColor"] as? String
        
        self.remarkTypeLabelText = options["remarkTypeLabelText"] as? String
        self.labelColor = options["labelColor"] as? String
        
        self.hintColor = options["hintColor"] as? String
        
        self.descriptionLabelText = options["descriptionLabelText"] as? String
        self.descriptionMaxLength = options["descriptionMaxLength"] as? Int
        self.descriptionHintText = options["descriptionHintText"] as? String
        
        self.inputTextColor = options["inputTextColor"] as? String 
        self.buttonText = options["buttonText"] as? String
        self.buttonTextColor = options["buttonTextColor"] as? String
        self.buttonBackgroundColor = options["buttonBackgroundColor"] as? String 

        // Init the Shake motion feature
        self.shakeGestureEnable = shakeGestureEnable
        
        // set once remark screen open
        if(self.shakeGestureEnable ?? false){
            _ = UIViewController.classInit
        }
        
        // To enable for managing distance between keyboard and textField.
        DispatchQueue.main.async {
            IQKeyboardManager.shared.enable = true
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
