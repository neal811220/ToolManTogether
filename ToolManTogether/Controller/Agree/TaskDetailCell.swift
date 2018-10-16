//
//  TaskDetailCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/16.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class TaskDetailCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTxtfield: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var taskAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
