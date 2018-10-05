//
//  ProfileDetailCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol ButtonDelegate: AnyObject {
    func doneBtnPressed(_ btnSend: UIButton,
                        _ phone: UITextField,
                        _ profileInfo: UITextView)
    
    func cancelBtnpressed(_ send: UIButton)
    func editBtnPressed(_ send: UIButton)
}

class ProfileDetailCell: UITableViewCell {
    
    @IBOutlet weak var profileTxtView: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var doneBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnHeight: NSLayoutConstraint!
    
    weak var btnDelegage: ButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileTxtView.layer.cornerRadius = 15
        phoneTxtField.layer.cornerRadius = 15
        profileTxtView.isEditable = false
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
        self.doneBtnHeight.constant = 0
        self.cancelBtnHeight.constant = 0
        profileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        btnDelegage?.doneBtnPressed(self.doneBtn,
                                    self.phoneTxtField,
                                    self.profileTxtView)
        
        UIView.animate(withDuration: 0.3) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.doneBtnHeight.constant = 0
        self.cancelBtnHeight.constant = 0
        profileTxtView.isEditable = false
        phoneTxtField.isEnabled = false
        editBtn.isHidden = false
        doneBtn.titleLabel?.isHidden = true
        cancelBtn.titleLabel?.isHidden = true
        doneBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        dismissBorder()
        btnDelegage?.cancelBtnpressed(self.cancelBtn)

        UIView.animate(withDuration: 0.3) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
            
        }
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        self.doneBtnHeight.constant = 36
        self.cancelBtnHeight.constant = 36
        profileTxtView.isEditable = true
        phoneTxtField.isEnabled = true
        editBtn.isHidden = true
        doneBtn.setTitle("Done", for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        setBorder()
        btnDelegage?.editBtnPressed(self.cancelBtn)

        UIView.animate(withDuration: 0.1) {
            self.doneBtn.layoutIfNeeded()
            self.cancelBtn.layoutIfNeeded()
            self.profileTxtView.layoutIfNeeded()
            self.phoneTxtField.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    func setBorder() {
        profileTxtView.layer.borderWidth = 1
        profileTxtView.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
        phoneTxtField.layer.borderWidth = 1
        phoneTxtField.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
    }
    
    func dismissBorder() {
        profileTxtView.layer.borderWidth = 0
        phoneTxtField.layer.borderWidth = 0
    }
}
