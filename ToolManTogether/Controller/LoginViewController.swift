//
//  LoginViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.backgroundColor = .clear
        fbButton.layer.borderWidth = 1
        fbButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        guestButton.layer.borderWidth = 1
        guestButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        setLayer()
        
       

    }
    
    
    @IBAction func connectFB(_ sender: Any) {
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
    
}
