//
//  AddTaskTypeCollectionViewCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class AddTaskTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeButtonView: UIView!
    @IBOutlet weak var typeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeButton.layer.cornerRadius = 18
        typeButton.layoutIfNeeded()
    }

}
