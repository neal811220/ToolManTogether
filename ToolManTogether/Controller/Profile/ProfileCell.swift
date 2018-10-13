//
//  ProfileCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/29.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userScoresLabel: UILabel!
    @IBOutlet weak var badgePhoto: UIImageView!
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        userPhoto.layer.cornerRadius = self.userPhoto.frame.height / 2
    }
    
}
