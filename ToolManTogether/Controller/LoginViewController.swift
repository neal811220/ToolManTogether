//
//  LoginViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UserNotifications
import FirebaseMessaging


class LoginViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    let manager = SPFacebookManager()
    var dataRef: DatabaseReference!
    let fbUserDefault: UserDefaults = UserDefaults.standard
    var userPhotoComplement: ((_ data: URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.backgroundColor = .clear
//        setButtonBorder()
//        setLayer()
        dataRef = Database.database().reference()
    }
    
    @IBAction func connectFB(_ sender: Any) {
        manager.facebookLogin(fromController: self, success: { [weak self] token in
            
            print("Successed \(token)")
            self?.getUserInfo(token: token)
            self?.switchView()

            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

            Auth.auth().signInAndRetrieveData(with: credential, completion:
                { (result, error) in
                if error == nil {
                    print("Firebase Success")
                } else {
                    print(error)
                }
            })
        }) { (error) in
            print(error)
        }
            
    }
    
    @IBAction func connectGuest(_ sender: Any) {
    }
    
    func setLayer() {
        let gradint = CAGradientLayer()
        gradint.frame = self.view.frame
        
        let leftColor: UIColor = #colorLiteral(red: 0.8, green: 0.6588235294, blue: 0.8980392157, alpha: 1)
        let rightColor: UIColor = #colorLiteral(red: 0.9411764706, green: 0.8784313725, blue: 0.8392156863, alpha: 1)
        gradint.colors = [leftColor.cgColor, rightColor.cgColor]
        
        gradint.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradint.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.view.layer.insertSublayer(gradint, below: bgView.layer)
    }
    
    func setButtonBorder() {
        fbButton.layer.borderWidth = 1
        fbButton.layer.borderColor = #colorLiteral(red: 0.9137254902, green: 0.8352941176, blue: 0.8431372549, alpha: 1)
        fbButton.layer.cornerRadius = 19
        guestButton.layer.borderWidth = 1
        guestButton.layer.borderColor = #colorLiteral(red: 0.9215686275, green: 0.8431372549, blue: 0.8431372549, alpha: 1)
        guestButton.layer.cornerRadius = 19
    }
    
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
            
            if error == nil {
                if let info = result as? [String: Any] {
                    print("info: \(info)")
                    
                    let fbID = info["id"] as? String
                    let fbName = info["name"] as? String
                    let fbEmail = info["email"] as? String
                    let fbPhoto = info["picture"] as? [String: Any]
                    let photoData = fbPhoto?["data"] as? [String: Any]
                    let photoURL = photoData?["url"] as? String
                    
                    self.uploadImagePic(url: URL(string: photoURL!)!)
                    
                    self.fbUserDefault.set(token, forKey: "token")
                    
                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    
                    self.dataRef.child("UserData").child(userID).updateChildValues([
                        "FBID": fbID,
                        "FBName": fbName,
                        "FBEmail": fbEmail,
                        "UserID": userID])
                }
            }
        })
    }
    
    func uploadImagePic(
        url: URL
        ) {
        
        let storageRef = Storage.storage().reference()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let data = try? Data(contentsOf: url) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child("UserPhoto").child(userId).putData(data, metadata: metaData) { (_, error) in
            if let error = error {
                return
            } else {
                print("Storage Success")
            }
        }
    }
    
    func switchView() {
        DispatchQueue.main.async {
            AppDelegate.shared?.window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
            
            guard let userID = Auth.auth().currentUser?.uid else { return }
        
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    
                    self.dataRef.child("UserData").child(userID).updateChildValues([
                        "RemoteToken": result.token])
                    
                    Messaging.messaging().subscribe(toTopic: "AllTask") { error in
                        print("Subscribed to AllTask topic")
                    }
                }
            }
        }
    }
}
