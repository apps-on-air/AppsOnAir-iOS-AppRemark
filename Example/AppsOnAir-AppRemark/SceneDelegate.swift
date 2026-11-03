//
//  SceneDelegate.swift
//  AppsOnAir-AppRemark
//

import UIKit

/// UIScene lifecycle is required for apps built with the iOS 27 SDK, the window is created from
/// Main.storyboard through UISceneStoryboardFile in Info.plist
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }
    }
}
