//
//  LoginViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    let manager = FacebookManager()
    var dataRef: DatabaseReference!
    let fbUserDefault: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.backgroundColor = .clear
        setButtonBorder()
        setLayer()
        dataRef = Database.database().reference()
    }
    
    @IBAction func connectFB(_ sender: Any) {
        manager.facebookLogin(fromController: self, success: { [weak self] token in
            
            self?.getUserInfo(token: token)
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential, completion:
                { (result, error) in
                if error == nil {
                    self!.uploadImagePic()
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
        
        let leftColor: UIColor = #colorLiteral(red: 0.3333333333, green: 0.3568627451, blue: 0.3882352941, alpha: 1)
        let rightColor: UIColor = #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3450980392, alpha: 1)
        gradint.colors = [leftColor.cgColor, rightColor.cgColor]
        
        gradint.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradint.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.view.layer.insertSublayer(gradint, below: bgView.layer)
    }
    
    func setButtonBorder() {
        fbButton.layer.borderWidth = 1
        fbButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        fbButton.layer.cornerRadius = 25
        guestButton.layer.borderWidth = 1
        guestButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        guestButton.layer.cornerRadius = 25
    }
    
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture"]).start(completionHandler: { (connection, result, error) in
            
            if error == nil {
                if let info = result as? [String: Any] {
                    print(info)
                    guard let fbID = info["id"] as? String else { return }
                    guard let fbName = info["name"] as? String else { return }
                    guard let fbEmail = info["email"] as? String else { return }
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    
                    self.fbUserDefault.set(token, forKey: "token")

                    self.dataRef.child("UserData").child(userId).setValue([
                        "FBID": fbID,
                        "FBName": fbName,
                        "FBEmail": fbEmail])
                }
            }
        })
    }
    
    func uploadImagePic(
        
        ) {
        
        let storageRef = Storage.storage().reference()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let photoUrl = Auth.auth().currentUser?.photoURL else { return }
        
        guard let data = try? Data(contentsOf: photoUrl) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child("UserPhoto").child(userId).putData(data, metadata: metaData) { (_, error) in
            
            if let error = error {
                
                return
                
            } else {
                
                print("Success")
//                storageRef.child(userId).child(fileName).downloadURL(completion: { (url, error) in
//
//                    if let error = error {
//
//                        failure(error)
//                    }
//
//                    if let url = url {
//
//                        success(url.absoluteString)
//                    }
//                })
            }
        }
    }
}
