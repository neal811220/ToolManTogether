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
    var titleCompletion: ((_ data: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let titleTxt = textField.text {
            titleCompletion?(titleTxt)
        }
    }
}
