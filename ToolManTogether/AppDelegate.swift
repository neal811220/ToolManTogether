//
//  AppDelegate.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let shared = UIApplication.shared.delegate as? AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        switchToLoginStoryBoard()
        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKSettings.setAppID("236162267244807")
        
        IQKeyboardManager.shared.enable = true
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        guard UserManager.fbUser.getUserToken() == nil else {
            
            switchToMainStoryBoard()
            return true
        }
        return true
    }
    
    func switchToLoginStoryBoard() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.switchToLoginStoryBoard()
            }
            return
        }
        
        window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController()
    }
    
    func switchToMainStoryBoard() {
        
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.switchToMainStoryBoard()
            }
            return
        }
        
        window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()

    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return result
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(
            application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return result
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
     
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
     
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

