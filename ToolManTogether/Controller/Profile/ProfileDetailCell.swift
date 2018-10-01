//
//  ProfileDetailCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ProfileDetailCell: UITableViewCell {
    
    @IBOutlet weak var perfileTxtView: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var doneBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        perfileTxtView.layer.cornerRadius = 15
        phoneTxtField.layer.cornerRadius = 15
        perfileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        doneBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        
        doneBtnHeight.constant = 0
        cancelBtnHeight.constant = 0
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        print("修改完成")
        self.doneBtnHeight.constant = 0
        self.cancelBtnHeight.constant = 0
        perfileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        
        UIView.animate(withDuration: 0.3) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.perfileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        print("取消修改")
        self.doneBtnHeight.constant = 0
        self.cancelBtnHeight.constant = 0
        perfileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        
        UIView.animate(withDuration: 0.3) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.perfileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
            
        }
    }
    
    
    @IBAction func editBtnPressed(_ sender: Any) {
        self.doneBtnHeight.constant = 36
        self.cancelBtnHeight.constant = 36
        perfileTxtView.isEditable = true
        phoneTxtField.isEnabled = true
        editBtn.isHidden = true
        doneBtn.setTitle("Done", for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        setBorder()

        UIView.animate(withDuration: 0.3) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.perfileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    func setBorder() {
        perfileTxtView.layer.borderWidth = 1
        perfileTxtView.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
        phoneTxtField.layer.borderWidth = 1
        phoneTxtField.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
    }
    
    func dismissBorder() {
        perfileTxtView.layer.borderWidth = 0
        phoneTxtField.layer.borderWidth = 0
    }
}
