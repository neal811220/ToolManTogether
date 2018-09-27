//
//  AddTaskTypeCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddTaskTypeCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var myRef: DatabaseReference!
    var typeTxtArray: [String] = []
    var typeTitleCompletion: ((_ data: String) -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let cellNib = UINib(nibName: "AddTaskTypeCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "addTaskTypeCollectionCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.collectionViewLayout = flowLayout
        
        myRef = Database.database().reference()
        getDataBaseType()
    }
    
    func getDataBaseType() {
        myRef.child("TaskType").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: String] else { return }
            for keys in value.keys {
                self.typeTxtArray.append(keys)
            }
            self.collectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeTxtArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addTaskTypeCollectionCell", for: indexPath) as? AddTaskTypeCollectionViewCell {
            if typeTxtArray.count != 0 {
                typeTxtArray.sort(by: >)
                cell.typeButton.setTitle(typeTxtArray[indexPath.row], for: .normal)
            }
            cell.typeButton.addTarget(self, action: #selector(typeButtonPressed), for: .touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    @objc func typeButtonPressed(button: UIButton) {
        if let typeButtonTxt = button.titleLabel?.text  {
            typeTitleCompletion?(typeButtonTxt)
        } else {
            typeTitleCompletion?("Type Button 無資料")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 137, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
