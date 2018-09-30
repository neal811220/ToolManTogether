//
//  ProfileServcedListCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ProfileServcedListCell: UITableViewCell {
    
    @IBOutlet weak var photoOne: UIImageView!
    @IBOutlet weak var photoTwo: UIImageView!
    @IBOutlet weak var photoThree: UIImageView!
    @IBOutlet weak var viewFour: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoOne.layer.cornerRadius = photoOne.frame.width / 2
        photoTwo.layer.cornerRadius = photoTwo.frame.width / 2
        photoThree.layer.cornerRadius = photoThree.frame.width / 2
        viewFour.layer.cornerRadius = viewFour.frame.width / 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
