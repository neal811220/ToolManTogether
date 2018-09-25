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
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let cellNib = UINib(nibName: "AddTaskTypeCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "addTaskTypeCollectionCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.minimumInteritemSpacing = 5.0
        self.collectionView.collectionViewLayout = flowLayout
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
//        let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell
//        self.cellDelegate?.collectionView(collectioncell: cell, didTappedInTableview: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
