//
//  SearchTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import FirebaseDatabase

class SearchTaskViewController: UIViewController {
    
    @IBOutlet weak var searchTaskTableVIew: UITableView!
    var photoURL: [URL] = []
    var myRef: DatabaseReference!
    var selectTask: [UserTaskInfo] = []
    var selectTaskKey: [String] = []
    var reloadFromFirebase = false
    var taskOwnerInfo: [RequestUserInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchNib = UINib(nibName: "searchTaskCell", bundle: nil)
        self.searchTaskTableVIew.register(searchNib, forCellReuseIdentifier: "searchTask")
        
        searchTaskTableVIew.delegate = self
        searchTaskTableVIew.dataSource = self
        
        myRef = Database.database().reference()
        selectTaskAdd()
        
        let notificationName = Notification.Name("sendRequest")
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectTaskAdd), name: notificationName, object: nil)


    }
    
    @objc func selectTaskAdd() {
        self.selectTask.removeAll()
        self.selectTaskKey.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else { return }

        myRef.child("RequestTask")
            .queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data {
                    guard let keyValue = value.key as? String else { return }
                    guard let dictionary = value.value as? [String: Any] else { return }
                    guard let title = dictionary["Title"] as? String else { return }
                    guard let content = dictionary["Content"] as? String else { return }
                    guard let price = dictionary["Price"] as? String else { return }
                    guard let type = dictionary["Type"] as? String else { return }
                    guard let userName = dictionary["UserName"] as? String else { return }
                    guard let userID = dictionary["UserID"] as? String else { return }
                    guard let taskLat = dictionary["Lat"] as? Double else { return }
                    guard let taskLon = dictionary["Lon"] as? Double else { return }
                    guard let checkTask = dictionary["checkTask"] as? String else { return }
                    guard let distance = dictionary["distance"] as? Double else { return }
                    guard let taskOwner = dictionary["ownerID"] as? String else { return }
                    let time = dictionary["Time"] as? Int
                    guard let ownerAgree = dictionary["OwnerAgree"] as? String else { return }
                    let requestUserkey = dictionary["requestUserKey"] as? String
                    let requestTaskKey = dictionary["taskKey"] as? String
                    
                    self.selectTaskKey.append(keyValue)
                    
                    let task = UserTaskInfo(userID: userID,
                                            userName: userName,
                                            title: title,
                                            content: content,
                                            type: type,
                                            price: price,
                                            taskLat: taskLat,
                                            taskLon: taskLon,
                                            checkTask: checkTask,
                                            distance: distance,
                                            time: time,
                                            ownerID: taskOwner,
                                            ownAgree: ownerAgree,
                                            taskKey: keyValue,
                                            agree: nil, requestKey: requestUserkey,
                                            requestTaskKey: requestTaskKey)
                    
                    self.selectTask.append(task)
                    self.selectTask.sort(by: { $0.time! > $1.time!})
                    
                    self.selectTaskChange(requestTaskKey: keyValue)

                }
                self.searchTaskTableVIew.reloadData()

            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func selectTaskChange(requestTaskKey: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

            myRef.child("RequestTask")
                .child(requestTaskKey)
                .observe(.childChanged) { (snapshot) in
                    
                    self.myRef.child("RequestTask")
                        .queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            self.selectTask.removeAll()
                            guard let data = snapshot.value as? NSDictionary else { return }
                            for value in data {
                                guard let keyValue = value.key as? String else { return }
                                guard let dictionary = value.value as? [String: Any] else { return }
                                guard let title = dictionary["Title"] as? String else { return }
                                guard let content = dictionary["Content"] as? String else { return }
                                guard let price = dictionary["Price"] as? String else { return }
                                guard let type = dictionary["Type"] as? String else { return }
                                guard let userName = dictionary["UserName"] as? String else { return }
                                guard let userID = dictionary["UserID"] as? String else { return }
                                guard let taskLat = dictionary["Lat"] as? Double else { return }
                                guard let taskLon = dictionary["Lon"] as? Double else { return }
                                guard let checkTask = dictionary["checkTask"] as? String else { return }
                                guard let distance = dictionary["distance"] as? Double else { return }
                                guard let taskOwner = dictionary["ownerID"] as? String else { return }
                                let time = dictionary["Time"] as? Int
                                guard let ownerAgree = dictionary["OwnerAgree"] as? String else { return }
                                let requestUserkey = dictionary["requestUserKey"] as? String
                                let requestTaskKey = dictionary["taskKey"] as? String

                                let task = UserTaskInfo(userID: userID,
                                                        userName: userName,
                                                        title: title,
                                                        content: content,
                                                        type: type,
                                                        price: price,
                                                        taskLat: taskLat,
                                                        taskLon: taskLon,
                                                        checkTask: checkTask,
                                                        distance: distance,
                                                        time: time,
                                                        ownerID: taskOwner,
                                                        ownAgree: ownerAgree,
                                                        taskKey: keyValue,
                                                        agree: nil, requestKey: requestUserkey, requestTaskKey: requestTaskKey)
                                
                                self.selectTask.append(task)
                                self.selectTask.sort(by: { $0.time! > $1.time!})
                            }
                            self.searchTaskTableVIew.reloadData()
                        }
            )}
    }
    
    
    func searchTaskOwnerInfo(ownerID: String) {
        
            myRef.child("UserData").queryOrderedByKey()
                .queryEqual(toValue: ownerID)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    self.taskOwnerInfo.removeAll()
                    guard let data = snapshot.value as? NSDictionary else { return }
                    for value in data.allValues {
                        
                        guard let dictionary = value as? [String: Any] else { return }
                        print(dictionary)
                        let aboutUser = dictionary["AboutUser"] as? String
                        let fbEmail = dictionary["FBEmail"] as? String
                        let fbID = dictionary["FBID"] as? String
                        let fbName = dictionary["FBName"] as? String
                        let userPhone = dictionary["UserPhone"] as? String
                        guard let userID = dictionary["UserID"] as? String else { return }
                        let remoteToken = dictionary["RemoteToken"] as? String
                        
                        let extractedExpr = RequestUserInfo(aboutUser: aboutUser,
                                                            fbEmail: fbEmail,
                                                            fbID: fbID,
                                                            fbName: fbName,
                                                            userPhone: userPhone, userID: userID,
                                                            remoteToken: remoteToken)
                        let toolsInfo = extractedExpr
                        self.taskOwnerInfo.append(toolsInfo)
                    }
                    let viewController = TaskAgreeViewController.profileDetailDataForTask(self.taskOwnerInfo)
                    self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SearchTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchTask", for: indexPath) as? SearchTaskCell {
            
            cell.searchTaskView.detailBtn.tag = indexPath.row
            cell.searchTaskView.reportBtn.tag = indexPath.row
            
            let cellData = selectTask[indexPath.row]
            cell.selectionStyle = .none
            cell.searchTaskView.taskTitleLabel.text = cellData.title
            cell.searchTaskView.userName.text = cellData.userName
            cell.searchTaskView.taskContentTxtView.text = cellData.content
            cell.searchTaskView.distanceLabel.text = "\(cellData.distance!)km"
            cell.searchTaskView.typeLabel.text = cellData.type
            cell.searchTaskView.priceLabel.text = cellData.price
            
            // 等待
            if cellData.ownAgree == "waiting" {
                cell.searchTaskView.sendButton.setTitle("尚未同意", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 1)
                cell.searchTaskView.detailBtn.isHidden = true
                cell.searchTaskView.sendButton.isEnabled = true
                cell.searchTaskView.sendButton.isHidden = false
                
            // 對方同意
            } else if cellData.ownAgree == "agree" {
                cell.isSelected = true
                cell.isEditing = true
                cell.searchTaskView.sendButton.setTitle("對方已經同意", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.5294117647, green: 0.6352941176, blue: 0.8509803922, alpha: 1)
                cell.searchTaskView.sendButton.isEnabled = false
                cell.searchTaskView.sendButton.isHidden = true
                
                cell.searchTaskView.detailBtn.isHidden = false
                
                
                if let ownerID = cellData.ownerID {
                    cell.searchTaskView.detailBtn.addTarget(self, action: #selector(detailBtnTapped(data:)), for: .touchUpInside)
                }
                
             // 對方拒絕
            } else if cellData.ownAgree == "disAgree" {
                cell.searchTaskView.sendButton.setTitle("對方已拒絕", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.6078431373, blue: 0.8, alpha: 1)
                cell.searchTaskView.detailBtn.isHidden = true
                cell.searchTaskView.sendButton.isEnabled = true
                cell.searchTaskView.sendButton.isHidden = false

                
             // 對方刪除
            } else if cellData.ownAgree == "delete" {
                cell.searchTaskView.sendButton.setTitle("對方已刪除任務", for: .normal)
                cell.searchTaskView.sendButton.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.4078431373, blue: 0.3019607843, alpha: 1)
                cell.searchTaskView.detailBtn.isHidden = true
                cell.searchTaskView.sendButton.isEnabled = true
                cell.searchTaskView.sendButton.isHidden = false

            }
            
            if let ownerID = cellData.ownerID {
                updataTaskUserPhoto(userID: ownerID) { (url) in
                    if url == url {
                        cell.searchTaskView.userPhoto.sd_setImage(with: url, completed: nil)
                    }
                }
            } else {
                cell.searchTaskView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
            }
            
            cell.searchTaskView.reportBtn.addTarget(self, action: #selector(showAlert(send:)), for: .touchUpInside)

            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
    @objc func detailBtnTapped(data: UIButton) {
        print("detail")
        let selectTaskOwner = selectTask[data.tag].ownerID
        if let taskOwnerID = selectTaskOwner {
            self.searchTaskOwnerInfo(ownerID: taskOwnerID)
        }
    }
    
    @objc func showAlert(send: UIButton) {
        
        let requestTask = selectTask[send.tag].checkTask
        
        let taskKey = selectTask[send.tag].requestTaskKey
        let userKey = selectTask[send.tag].requestKey

        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們會儘快處理", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: nil)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let deltetAction = UIAlertAction(title: "從列表中刪除", style: .default) { (void) in
            let reportController = UIAlertController(title: "確定刪除？", message: "刪除後將無法再看到該任務", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: { (void) in
                
                if let requestTaskKey = requestTask {
                    self.myRef.child("RequestTask").queryOrdered(byChild: "checkTask").queryEqual(toValue: requestTaskKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let data = snapshot.value as? NSDictionary else { return }
                        
                        for value in data {
                            guard let keyValue = value.key as? String else { return }
                            
                            self.myRef.child("RequestTask").child(keyValue).removeValue()
                            let index = IndexPath(row: send.tag, section: 0)
                            self.selectTask.remove(at: send.tag)
                            
                            if let userKey = userKey, let taskKey = taskKey {
                                
                               print(taskKey)
                               print(userKey)
                                self.myRef.child("Task").child(taskKey).child("RequestUser").child(userKey).removeValue()
                            }
                            
                            self.searchTaskTableVIew.performBatchUpdates({
                                self.searchTaskTableVIew.deleteRows(at: [index], with: .left)
                                
                            }, completion: {
                                (finished: Bool) in
                                self.searchTaskTableVIew.reloadData()
                                print("刪除完成")
                            })
                        }
                    })
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        personAlertController.addAction(reportAction)
        personAlertController.addAction(deltetAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
    

    

    
    func updataTaskUserPhoto(
        userID: String,
        success: @escaping (URL) -> Void) {
        
        let storageRef = Storage.storage().reference()
        
        storageRef.child("UserPhoto").child(userID).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            if let url = url {
                print("url \(url)")
                success(url)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    @objc func requestBtnPressed() {
        
        let storyBoard = UIStoryboard(name: "TaskAgree", bundle: nil)
        
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "taskAgreeVC") as? TaskAgreeViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
