//
//  RequestCollectionViewCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/28.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class RequestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var requestCollectionView: TaskDetailInfoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requestCollectionView.layer.cornerRadius = 22
        requestCollectionView.layer.borderWidth = 1
        requestCollectionView.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.7215686275, blue: 0, alpha: 1)
        requestCollectionView.separatorView.isHidden = true
        requestCollectionView.sendButton.backgroundColor = #colorLiteral(red: 1, green: 0.6588235294, blue: 0.662745098, alpha: 1)
    }

}
