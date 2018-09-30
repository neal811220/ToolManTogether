//
//  TaskAgreeInfoCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class TaskAgreeInfoCell: UITableViewCell {

    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var callBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBtn.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func callBtnTapped(_ sender: Any) {
        print("打電話")
    }
    
    
}
