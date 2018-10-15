//
//  GoodCitizenCardCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Lottie


protocol selectPhotoDelegate: AnyObject {
    func selectBtnPressed(_ btnSend: UIButton, _ imageView: UIImageView)
}

class GoodCitizenCardCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var imagePicker: UIImageView!
    weak var photoBtnDelegage: selectPhotoDelegate?
    @IBOutlet weak var aniView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var updateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectButton.isHidden = true
        setAniView()
        
        selectButton.layer.borderColor = #colorLiteral(red: 0.7450980392, green: 0.6588235294, blue: 0.6274509804, alpha: 1)
        selectButton.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func selectBtn(_ sender: Any) {
        
        photoBtnDelegage?.selectBtnPressed(self.selectButton, self.imagePicker)
    }
    
    func setAniView() {
        let animationView = LOTAnimationView(name: "cloud")
        animationView.frame = aniView.frame
        animationView.center = aniView.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        
        bgView.addSubview(animationView)
        
        animationView.play()
    }
    
    
}
