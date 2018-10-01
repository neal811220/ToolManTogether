//
//  ScoreSendView.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ScoreSendView: UIView {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        submitBtn.layer.cornerRadius = 13
        contentTxtView.layer.borderWidth = 1
        contentTxtView.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ScoreSendView", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    @IBAction func submit(_ sender: Any) {
        print("送出評分")
    }
    
    
}

