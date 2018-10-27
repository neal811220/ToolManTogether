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
import UserNotifications
import KeychainSwift

import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var myRef: DatabaseReference!
    var taskOwnerInfo: [RequestUserInfo] = []
    var taskInfo: [UserTaskInfo] = []

    static let shared = UIApplication.shared.delegate as? AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        switchToLoginStoryBoard()
        
        let keychain = KeychainSwift()
        
        window?.tintColor = UIColor.init(red: 242.0/255.0, green: 183.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        Fabric.with([Crashlytics.self])
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKSettings.setAppID("236162267244807")

        IQKeyboardManager.shared.enable = true

        IQKeyboardManager.shared.enableAutoToolbar = false

        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        myRef = Database.database().reference()

        guard UserManager.fbUser.getUserToken() == nil else {
            
            switchToMainStoryBoard()
            
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    keychain.set(result.token, forKey: "remoteToken")
                }
            }
            
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.

        // Print full message.
//        let testVC = window?.rootViewController as? UITabBarController
//        let storyboard = UIStoryboard(name: "cusomeAlert", bundle: nil)
//        let testVC2 = storyboard.instantiateViewController(withIdentifier: "cusomeAlert")
//        window?.rootViewController?.show(testVC2, sender: nil)
        print(userInfo)
        
        guard let data = userInfo as? NSDictionary else { return }
        print(data)
        
        if let value = data["type"] as? String {
            switch value {
                
            case "message":
                
                let fromUserId = data["fromUserId"] as? String
                let taskInfoKey = data["taskInfoKey"] as? String
                getMessageNeedData(fromUserId: fromUserId, taskInfoKey: taskInfoKey)
                
            case "mission":
                print("mission waiting doing")
    
            default:
                return
            }
        }
        
//        AppDelegate.shared?.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        AppDelegate.shared?.window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
//        let tabBarVC = AppDelegate.shared?.window?.rootViewController as? TabBarViewController
//        tabBarVC?.selectedIndex = 1
//        UIApplication.shared.applicationIconBadgeNumber = 0
    
        // 推播 show view

//
//        AppDelegate.shared?.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        AppDelegate.shared?.window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
//        let storyboard = UIStoryboard(name: "NotificationAgree", bundle: nil)
//        let alertVC = storyboard.instantiateViewController(withIdentifier: "NotificationAgree")
//        let tabBarVC = AppDelegate.shared?.window?.rootViewController as? TabBarViewController
//        let testVC = NotificationAgreeViewController.profileDetailDataForTask("test")
//        tabBarVC?.present(testVC, animated: true, completion: nil)
//        tabBarVC?.selectedIndex = 1
//        UIApplication.shared.applicationIconBadgeNumber = 0

    }
    
    func getMessageNeedData(fromUserId: String?, taskInfoKey: String?) {
        
        let myTabBar = self.window?.rootViewController as? UITabBarController
        
        let navViewController = myTabBar?.selectedViewController as? UINavigationController
        
        navViewController?.popViewController(animated: false)
        
        let myId = Auth.auth().currentUser?.uid
        
        myRef.child("Task").queryOrderedByKey().queryEqual(toValue: taskInfoKey!).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let data = snapshot.value as? NSDictionary else { return }
            
            for value in data {
                
                guard let keyValue = value.key as? String else { return }
                guard let dictionary = value.value as? [String: Any] else { return }
                print(dictionary)
                
                guard let title = dictionary["Title"] as? String else { return }
                guard let content = dictionary["Content"] as? String else { return }
                guard let price = dictionary["Price"] as? String else { return }
                guard let type = dictionary["Type"] as? String else { return }
                guard let userName = dictionary["UserName"] as? String else { return }
                guard let userID = dictionary["UserID"] as? String else { return }
                guard let requestUser = dictionary["RequestUser"] as? NSDictionary else { return }
    
                let taskLat = dictionary["lat"] as? Double
                let taskLon = dictionary["lon"] as? Double
                guard let agree = dictionary["agree"] as? Bool else { return }
                let time = dictionary["Time"] as? Int
                
                let task = UserTaskInfo(userID: userID,
                                        userName: userName,
                                        title: title,
                                        content: content,
                                        type: type, price: price,
                                        taskLat: taskLat, taskLon: taskLon, checkTask: nil,
                                        distance: nil, time: time,
                                        ownerID: nil, ownAgree: nil,
                                        taskKey: keyValue, agree: agree, requestKey: nil,
                                        requestTaskKey: nil, address: nil)
                self.taskInfo.append(task)
                
            }
        }
            
            myRef.child("UserData").queryOrderedByKey()
                .queryEqual(toValue: fromUserId!)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let data = snapshot.value as? NSDictionary else { return }
                    for value in data.allValues {
                        
                        guard let dictionary = value as? [String: Any] else { return }
                        print(dictionary)
                        let aboutUser = dictionary["AboutUser"] as? String
                        let fbEmail = dictionary["FBEmail"] as? String
                        let fbID = dictionary["FBID"] as? String
                        let fbName = dictionary["FBName"] as? String
                        let userPhone = dictionary["UserPhone"] as? String
                        guard let userID = dictionary["UserID"] as? String else { return }
                        let remoteToken = dictionary["RemoteToken"] as? String
                        
                        let extractedExpr = RequestUserInfo(aboutUser: aboutUser,
                                                            fbEmail: fbEmail,
                                                            fbID: fbID,
                                                            fbName: fbName,
                                                            userPhone: userPhone, userID: userID,
                                                            remoteToken: remoteToken)
                        self.taskOwnerInfo.append(extractedExpr)
                    }
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0

                    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                    chatLogController.taskInfo = self.taskInfo.last
                    chatLogController.userInfo = self.taskOwnerInfo.last
                    chatLogController.findRequestUserRemoteToken = self.taskOwnerInfo.last?.userID
                    chatLogController.fromTaskOwner = true
                    navViewController?.pushViewController(chatLogController, animated: false)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
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
