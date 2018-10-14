//
//  AddTaskInfoCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class AddTaskInfoCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleCompletion: ((_ data: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        
        textField.layer.shadowColor = UIColor.darkGray.cgColor
//        textField.layer.cornerRadius = 10
        textField.layer.shadowRadius = 1
        textField.layer.shadowOpacity = 0.5
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        let claneDataNotification = Notification.Name("addTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanData), name: claneDataNotification, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let titleTxt = textField.text {
            titleCompletion?(titleTxt)
        }
    }
    
    @objc func cleanData() {
        textField.text = ""
    }
    

}
