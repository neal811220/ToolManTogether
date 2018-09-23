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
        setLayer()
    }
    
    func setLayer() {
        let gradint = CAGradientLayer()
        gradint.frame = self.typeButtonView.frame
        
        let leftColor: UIColor = #colorLiteral(red: 1, green: 0.5647058824, blue: 0.3058823529, alpha: 1)
        let rightColor: UIColor = #colorLiteral(red: 0.7843137255, green: 0.1294117647, blue: 0.3294117647, alpha: 1)
        gradint.colors = [leftColor.cgColor, rightColor.cgColor]
        
        gradint.startPoint = CGPoint(x: 0, y: 0.5)
        gradint.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.typeButtonView.layer.insertSublayer(gradint, below: typeButton.layer)
    }

}
