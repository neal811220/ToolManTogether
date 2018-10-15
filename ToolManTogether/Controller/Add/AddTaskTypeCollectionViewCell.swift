//
//  AddTaskTypeCollectionViewCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol TypeBtnPressed: AnyObject {
    func typeSelect(_ cell: UICollectionViewCell)
}

class AddTaskTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeButtonView: UIView!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var underLineView: UIView!
    
    weak var typeDelegate: TypeBtnPressed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeButton.layer.cornerRadius = 18
        typeButton.layoutIfNeeded()
        
    }

    @IBAction func typeBtnPressed(_ sender: Any) {
        typeDelegate?.typeSelect(self)
    }
    
//    override func prepareForReuse() {
//        if self.typeButton.backgroundColor == #colorLiteral(red: 0.9411764706, green: 0.4078431373, blue: 0.3019607843, alpha: 1) {
//            self.typeButton.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.4078431373, blue: 0.3019607843, alpha: 1)
//        } else if typeButton.backgroundColor == #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) {
//            self.typeButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        }
//    }
}
