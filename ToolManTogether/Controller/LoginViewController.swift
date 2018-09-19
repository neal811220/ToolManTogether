//
//  LoginViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    let manager = FacebookManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.backgroundColor = .clear
        setButtonBorder()
        setLayer()

    }
    
    @IBAction func connectFB(_ sender: Any) {
        manager.facebookLogin(fromController: self, success: { [weak self] token in
            self?.getUserInfo(token: token)
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func connectGuest(_ sender: Any) {
    }
    
    func setLayer() {
        let gradint = CAGradientLayer()
        gradint.frame = self.view.frame
        
        let leftColor: UIColor = #colorLiteral(red: 0.7843137255, green: 0.4274509804, blue: 0.8431372549, alpha: 1)
        let rightColor: UIColor = #colorLiteral(red: 0.1882352941, green: 0.137254902, blue: 0.6823529412, alpha: 1)
        gradint.colors = [leftColor.cgColor, rightColor.cgColor]
        
        gradint.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradint.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        self.view.layer.insertSublayer(gradint, below: bgView.layer)
    }
    
    func setButtonBorder() {
        fbButton.layer.borderWidth = 1
        fbButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        guestButton.layer.borderWidth = 1
        guestButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
    }
    
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) in
            
            if error == nil {
                if let info = result as? [String: Any] {
                    print(info)
                    guard let userID = info["id"] as? String else { return }
                    guard let userName = info["name"] as? String else { return }
                    guard let userEmail = info["email"] as? String else { return }
                    print(userID)
                    print(userName)
                    print(userEmail)
                }
              
            }
        })
    }
    
}
