//
//  GoodCitizenCardCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

protocol selectPhotoDelegate: AnyObject {
    func selectBtnPressed(_ btnSend: UIButton, _ imageView: UIImageView)
}

class GoodCitizenCardCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var imagePicker: UIImageView!
    weak var photoBtnDelegage: selectPhotoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func selectBtn(_ sender: Any) {
        
        photoBtnDelegage?.selectBtnPressed(self.selectButton, self.imagePicker)
        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            var imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.allowsEditing = true
        
//        }
        
    }
    
    
}
