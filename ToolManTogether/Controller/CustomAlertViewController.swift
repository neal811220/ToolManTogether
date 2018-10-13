//
//  CustomAlertViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/8.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Lottie

class CustomAlertViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var aniView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isOpaque = false
        self.view.backgroundColor = .clear
        
         let animationView = LOTAnimationView(name: "check_animation")
            animationView.frame = aniView.frame
            animationView.center = aniView.center
            animationView.contentMode = .scaleAspectFill
            
            bgView.addSubview(animationView)
            
            animationView.play()
        
    }
}
