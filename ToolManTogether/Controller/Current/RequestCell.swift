//
//  RequestCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/28.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import FirebaseDatabase

protocol ScrollTask: AnyObject{
    func didScrollTask(_ cell: String)
}

class RequestCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let layout = AnimatedCollectionViewLayout()
    let screenSize = UIScreen.main.bounds.size
    var myRef: DatabaseReference!
    var addTask: [UserTaskInfo] = []
    private var indexOfCellBeforeDragging = 0
    weak var scrollTaslDelegate: ScrollTask?
    var checkIndex = 0
    
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
        
        myRef = Database.database().reference()
        createTaskAdd()
        
        let notificationName = Notification.Name("addTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.createTaskAdd), name: notificationName, object: nil)
        
    }
    
    @objc func createTaskAdd () {
        
        self.addTask.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("Task").queryOrdered(byChild: "UserID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }

            for value in data.allValues {
                
                guard let dictionary = value as? [String: Any] else { return }
                guard let title = dictionary["Title"] as? String else { return }
                guard let content = dictionary["Content"] as? String else { return }
                guard let price = dictionary["Price"] as? String else { return }
                guard let type = dictionary["Type"] as? String else { return }
                guard let userName = dictionary["UserName"] as? String else { return }
                guard let userID = dictionary["UserID"] as? String else { return }
                guard let taskLat = dictionary["lat"] as? Double else { return }
                guard let taskLon = dictionary["lon"] as? Double else { return }
                let time = dictionary["Time"] as? Int

                let task = UserTaskInfo(userID: userID,
                                        userName: userName,
                                        title: title,
                                        content: content,
                                        type: type, price: price,
                                        taskLat: taskLat, taskLon: taskLon, checkTask: nil,
                                        distance: nil, time: time)
                self.addTask.append(task)
                self.addTask.sort(by: { $0.time! > $1.time! })

            }
            self.collectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollIndex = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        print(scrollView)
        print(scrollIndex)
        print(scrollView.contentOffset.x)
        print(scrollView.frame.width)
        
        if scrollIndex != checkIndex {
            let searchAnnotation = "\(addTask[scrollIndex].taskLat)_\(addTask[scrollIndex].taskLon)"
            scrollTaslDelegate?.didScrollTask(searchAnnotation)
            checkIndex = scrollIndex
        } else {
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addTask.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCollectionView", for: indexPath) as? RequestCollectionViewCell {
            let cellData = addTask[indexPath.row]
            cell.requestCollectionView.taskTitleLabel.text = cellData.title
            cell.requestCollectionView.taskContentTxtView.text = cellData.content
            cell.requestCollectionView.sendButton.setTitle("Cancel", for: .normal)
            cell.requestCollectionView.priceLabel.text = cellData.price
            cell.requestCollectionView.typeLabel.text = cellData.type
            cell.requestCollectionView.distanceLabel.isHidden = true
            self.titleLabel.text = "\(addTask.count)"
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
