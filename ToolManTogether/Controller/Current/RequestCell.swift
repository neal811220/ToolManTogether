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
import Lottie

protocol ScrollTask: AnyObject{
    func didScrollTask(_ cell: UserTaskInfo)
}

protocol btnPressed: AnyObject {
    func btnPressed(_ send: TaskDetailInfoView)
}

class RequestCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var taskNumTitleLabel: UILabel!
    @IBOutlet weak var toosNumTitleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var aniView: UIView!
    
    let layout = AnimatedCollectionViewLayout()
    let screenSize = UIScreen.main.bounds.size
    var myRef: DatabaseReference!
    var addTask: [UserTaskInfo] = []
    var addTaskKey: [String] = []
    private var indexOfCellBeforeDragging = 0
    weak var scrollTaskDelegate: ScrollTask?
    weak var scrollTaskBtnDelegate: btnPressed?
    var checkIndex = 0
    var scrollIndex = 0
//    var bgView: UIView?
    
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
        
        let addTaskNotification = Notification.Name("addTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.createTaskAdd), name: addTaskNotification, object: nil)
        
        let agreeToolNotification = Notification.Name("agreeToos")
        NotificationCenter.default.addObserver(self, selector: #selector(self.createTaskAdd), name: agreeToolNotification, object: nil)
        
        
    }
    
    func changeView(addTask:DataSnapshot) {

        if addTask.hasChildren() == false {
            NotificationCenter.default.post(name: .noTask, object: nil)
        } else {
            NotificationCenter.default.post(name: .hasTask, object: nil)
        }
    }

    // 已發任務
    
    @objc func createTaskAdd () {
        
        self.addTask.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("Task").queryOrdered(byChild: "UserID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            
            print(snapshot)
            self.changeView(addTask: snapshot)
            
            guard let data = snapshot.value as? NSDictionary else { return }
            
            for value in data {
                
                guard let keyValue = value.key as? String else { return }
                guard let dictionary = value.value as? [String: Any] else { return }
                print(dictionary)
                
                guard let title = dictionary["Title"] as? String else { return }
                guard let content = dictionary["Content"] as? String else { return }
                guard let price = dictionary["Price"] as? String else { return }
                guard let type = dictionary["Type"] as? String else { return }
                guard let userName = dictionary["UserName"] as? String else { return }
                guard let userID = dictionary["UserID"] as? String else { return }
                
                let taskLat = dictionary["lat"] as? Double
                let taskLon = dictionary["lon"] as? Double
                guard let agree = dictionary["agree"] as? Bool else { return }
                let time = dictionary["Time"] as? Int

                let task = UserTaskInfo(userID: userID,
                                        userName: userName,
                                        title: title,
                                        content: content,
                                        type: type, price: price,
                                        taskLat: taskLat, taskLon: taskLon, checkTask: nil,
                                        distance: nil, time: time,
                                        ownerID: nil, ownAgree: nil,
                                        taskKey: keyValue, agree: agree, requestKey: nil, requestTaskKey: nil, address: nil)
                
                self.addTask.append(task)
                self.addTask.sort(by: { $0.time! > $1.time! })
                
//                self.createTaskChange(taskKey: keyValue)
            }
            
            self.collectionView.reloadData()
            let searchAnnotation = self.addTask[self.scrollIndex]
            self.scrollTaskDelegate?.didScrollTask(searchAnnotation)
            self.taskNumTitleLabel.text = "第 \(self.scrollIndex + 1) / \(self.addTask.count) 筆任務"

        }
    }
    
    func createTaskChange(taskKey: String) {

        guard let userID = Auth.auth().currentUser?.uid else { return }

        myRef.child("Task").child(taskKey).child("RequestUser").observe(.childAdded) { (snapshot) in
            
            print(snapshot)

            self.myRef.child("Task").queryOrdered(byChild: "UserID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in

                self.addTask.removeAll()

                print(snapshot)
                guard let data = snapshot.value as? NSDictionary else { return }

                for value in data {

                    guard let keyValue = value.key as? String else { return }
                    guard let dictionary = value.value as? [String: Any] else { return }
                    print(dictionary)
                    guard let title = dictionary["Title"] as? String else { return }
                    guard let content = dictionary["Content"] as? String else { return }
                    guard let price = dictionary["Price"] as? String else { return }
                    guard let type = dictionary["Type"] as? String else { return }
                    guard let userName = dictionary["UserName"] as? String else { return }
                    guard let userID = dictionary["UserID"] as? String else { return }
                    let taskLat = dictionary["lat"] as? Double
                    let taskLon = dictionary["lon"] as? Double
                    guard let agree = dictionary["agree"] as? Bool else { return }
                    let time = dictionary["Time"] as? Int

                    let task = UserTaskInfo(userID: userID,
                                            userName: userName,
                                            title: title,
                                            content: content,
                                            type: type, price: price,
                                            taskLat: taskLat, taskLon: taskLon, checkTask: nil,
                                            distance: nil, time: time,
                                            ownerID: nil, ownAgree: nil,
                                            taskKey: keyValue, agree: agree, requestKey: nil, requestTaskKey: nil, address: nil)
                    self.addTask.append(task)
                    self.addTask.sort(by: { $0.time! > $1.time! })
                    
                }
                
                self.collectionView.reloadData()
                let searchAnnotation = self.addTask[self.checkIndex]
                self.scrollTaskDelegate?.didScrollTask(searchAnnotation)
            }
        }
    }
    
    
    // 滑動結束觸發
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.x)
        print(scrollView.frame.width)
        print(Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
        
        scrollIndex = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        
        print(scrollIndex)
        
        if scrollIndex != checkIndex {
            let searchAnnotation = addTask[scrollIndex]
            scrollTaskDelegate?.didScrollTask(searchAnnotation)
            checkIndex = scrollIndex
            self.taskNumTitleLabel.text = "第 \(checkIndex + 1) / \(addTask.count) 筆任務"

        } else {
        }
    }
    
    func downloadUserPhoto(
        userID: String,
        finder: String,
        success: @escaping (URL) -> Void) {
        
        let storageRef = Storage.storage().reference()
        
        storageRef.child(finder).child(userID).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            if let url = url {
                print("url \(url)")
                success(url)
            }
        })
    }

    
    // 刪除任務
    @objc func deleteScrollTask() {
        
        guard addTask.count != 0 else {
            NotificationCenter.default.post(name: .noTask, object: nil)
            return
        }
        
        guard addTask.count != scrollIndex else { return }
        let userId = Auth.auth().currentUser?.uid
        guard let ownerTaskKey = addTask[scrollIndex].taskKey else { return }
        
        myRef.child("Task").child(ownerTaskKey).removeValue()
        myRef.child("userAllTask").child(userId!).child(ownerTaskKey).removeValue()
        self.addTask.remove(at: scrollIndex)
        
        let index = IndexPath(row: scrollIndex, section: 0)
        self.collectionView.performBatchUpdates({
        
            self.collectionView.deleteItems(at: [index])
            
            print(checkIndex)
            print(addTask.count)
            print(scrollIndex)
            
            if checkIndex == 0 {
                checkIndex = 1
            }
            
            self.taskNumTitleLabel.text = "第 \((checkIndex)) / \(addTask.count) 筆任務"
            
            if addTask.count == 0 {
                NotificationCenter.default.post(name: .noTask, object: nil)
            }

        }, completion: {
            (finished: Bool) in
        })
        print("刪除完成")
    }

    // 完成，刪除任務
    @objc func doneDelect() {
        
        guard addTask.count != 0 else {
            NotificationCenter.default.post(name: .noTask, object: nil)
            return
        }
        
        guard addTask.count != scrollIndex else { return }
        let userId = Auth.auth().currentUser?.uid
        guard let taskKey = addTask[scrollIndex].taskKey else { return }
        
        myRef.child("Task").child(taskKey).removeValue()
        myRef.child("userAllTask").child(userId!).child(taskKey).removeValue()
        self.addTask.remove(at: scrollIndex)

        let index = IndexPath(row: scrollIndex, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [index])
            
            if checkIndex == 0 {
                checkIndex = 1
            }
            self.taskNumTitleLabel.text = "第 \((checkIndex)) / \(addTask.count) 筆任務"
            
            if addTask.count == 0 {
                NotificationCenter.default.post(name: .noTask, object: nil)
            }
            
        }, completion: {
            (finished: Bool) in
        })
        print("刪除完成")
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
            cell.taskBtnDelegate = self
            cell.requestCollectionView.taskTitleLabel.text = cellData.title
            cell.requestCollectionView.taskContentTxtView.text = cellData.content
            cell.requestCollectionView.priceLabel.text = cellData.price
            cell.requestCollectionView.typeLabel.text = cellData.type
            cell.requestCollectionView.userName.text = cellData.userName
            cell.requestCollectionView.reportBtn.isHidden = true
            cell.requestCollectionView.contentView.layer.cornerRadius = 23
            cell.requestCollectionView.sendButton.layer.cornerRadius = 10
            cell.requestCollectionView.separatorView.isHidden = true
            cell.requestCollectionView.downView.isHidden = true
            
            
            if cellData.agree == false {
                cell.requestCollectionView.sendButton.setTitle("取消任務", for: .normal)
                cell.requestCollectionView.sendButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                cell.requestCollectionView.donBtn.isHidden = true
                cell.requestCollectionView.sendButton.isHidden = false
                cell.requestCollectionView.sendButton.addTarget(self, action: #selector(deleteScrollTask), for: .touchUpInside)

            } else if cellData.agree == true {
                cell.requestCollectionView.sendButton.isHidden = true
                cell.requestCollectionView.donBtn.isHidden = false
                

                // 完成刪除
                cell.requestCollectionView.donBtn.addTarget(self, action: #selector(doneDelect), for: .touchUpInside)
                
            } else {
                cell.requestCollectionView.sendButton.setTitle("取消任務", for: .normal)
                cell.requestCollectionView.sendButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                cell.requestCollectionView.donBtn.isHidden = true
                cell.requestCollectionView.sendButton.isHidden = false

            }
           
            downloadUserPhoto(userID: cellData.userID, finder: "UserPhoto") { (url) in
                if url == url {
                    cell.requestCollectionView.userPhoto.sd_setImage(with: url, completed: nil)
                } else {
                    cell.requestCollectionView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
                }
            }

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

extension RequestCell: ScrollTaskBtn{
    
    func didPressed(_ scrollView: TaskDetailInfoView) {
        scrollTaskBtnDelegate?.btnPressed(scrollView)
    }
}

extension Notification.Name {
    static let noTask = Notification.Name("noTask")
    static let hasTask = Notification.Name("hasTask")
}
