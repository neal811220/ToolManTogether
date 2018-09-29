//
//  RequestCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/28.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout


class RequestCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let layout = AnimatedCollectionViewLayout()
    
    let screenSize = UIScreen.main.bounds.size
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellNib = UINib(nibName: "RequestCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "requestCollectionView")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        
        self.collectionView.showsHorizontalScrollIndicator = false
        layout.animator = PageAttributesAnimator()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCollectionView", for: indexPath) as? RequestCollectionViewCell {
            print(indexPath.row)
            cell.requestCollectionView.sendButton.setTitle("Cancel", for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 298)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

}
