//
//  AppDelegate.swift
//  AppsOnAir-AppRemark
//
//  Created by 164989979 on 10/01/2024.
//  Copyright (c) 2024 164989979. All rights reserved.
//

import UIKit
import AppsOnAir_AppRemark

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appRemarkService = AppRemarkService.shared

    //selected from the dropdown in ViewController, used on initialize
    static var shakeSensitivity = ShakeSensitivity.medium

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options: NSDictionary = [
            "pageBackgroundColor": "#007AFF",
            "appBarBackgroundColor": "#1c1c9e",
            "descriptionLabelText": "Add description here",
            "appBarTitleColor": "#FFFFFF",
            "remarkTypeLabelText": "Add Remark here",
            "descriptionHintText": "Add description here..",
            "descriptionMaxLength": 120,
            "buttonText": "Submit Remark",
            "buttonTextColor": "#000000",
            "labelColor": "#FFFFFF",
            "buttonBackgroundColor": "#FFFFFF",
            "inputTextColor": "#000000",
            "hintColor": "#000000",
            "appBarTitleText": "Feedback Screen"
        ]

        //with default theme
        //appRemarkService.initialize { remarkInfo in }
        //with customize theme
        //shakeGestureEnable is set to true by default, allowing the device to capture your current screen when it shakes. If it is false, the device shake's auto-capture screen will be disabled.
        //shakeSensitivity is optional, without it the system shake gesture is used. Use .veryLow/.low to require a harder shake or .high/.veryHigh to trigger on a lighter one.
        appRemarkService.initialize(
            shakeGestureEnable: true,
            options: options,
            shakeSensitivity: AppDelegate.shakeSensitivity
        ) { remarkInfo in
            print("AppRemark", remarkInfo)
        }

        appRemarkService.setAdditionalMetaData(extraPayload: [
            "userId": "USER_ID",
            "isShake": true
        ])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

