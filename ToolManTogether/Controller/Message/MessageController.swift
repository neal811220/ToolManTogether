//
//  MessageController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/24.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging


class MessageController: UIViewController {
    
    @IBOutlet weak var messageListTableView: UITableView!
    var myRef: DatabaseReference!
    var userAllTaskKey: [MessageTaskKey] = []
    var userAllMessage: [Message] = []
    var messagesDictionary = [String: Message]()
    var taskInfo: [UserTaskInfo] = []
    var taskOwnerInfo: [RequestUserInfo] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageListTableView.allowsSelection = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        myRef = Database.database().reference()
        
        let messageListNib = UINib(nibName: "controllerMessage", bundle: nil)
        self.messageListTableView.register(messageListNib, forCellReuseIdentifier: "controllerMessage")
        
        getUserAkkTaskKey()
        
        self.title = "任務聊天室"
    }
    
    func getUserAkkTaskKey() {
        
        let userId = Auth.auth().currentUser?.uid
        myRef.child("userAllTask").queryOrderedByKey()
            .queryEqual(toValue: userId!)
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let `self` = self else { return }
                    for taskValue in dictionary.values {
                        guard let dictionaryValue = taskValue as? [String: String] else { return }
                        guard let taskKey = dictionaryValue["taskKey"] else { return }
                        guard let taskTitle = dictionaryValue["taskTitle"] else { return }
                        guard let taskOwnerName = dictionaryValue["taskOwnerName"] else { return }
                        let data = MessageTaskKey(taskKey: taskKey, taskTitle: taskTitle, taskOwnerName: taskOwnerName)
                        self.userAllTaskKey.append(data)
                    }
                }
                self?.messageListTableView.reloadData()
                self?.getMessageListByKey()
        }
    }
    
    func getMessageListByKey() {
        
        let userId = Auth.auth().currentUser?.uid
        
        for data in userAllTaskKey {
            print(data)
            myRef.child("Message")
                .child(data.taskKey)
                .observe(.childAdded) { [weak self] (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        //                        let taskKey = snapshot.key as? String
                        let fromId = dictionary["fromId"] as? String
                        let text = dictionary["message"] as? String
                        let timestamp = dictionary["timestamp"] as? Double
                        let imageUrl = dictionary["imageUrl"] as? String
                        let taskTitle = dictionary["taskTitle"] as? String
                        let taskOwnerName = dictionary["taskOwnerName"] as? String
                        let taskOwnerId = dictionary["taskOwnerId"] as? String
                        let taskKey = dictionary["taskKey"] as? String
                        let taskType = dictionary["taskType"] as? String
                        
                        
                        let message = Message(fromId: fromId, text: text,
                                              timestamp: timestamp, taskTitle: taskTitle,
                                              taskOwnerName: taskOwnerName,
                                              taskOwnerId: taskOwnerId, taskKey: taskKey,
                                              taskType: taskType, imageUrl: imageUrl,imageHeight: nil,
                                              imageWidth: nil)
                        
                        guard let stroungSelf = self else { return }
                        
                        //                        if message.fromId != userId {
                        
                        stroungSelf.messagesDictionary[data.taskKey] = message
                        
                        stroungSelf.userAllMessage = Array(stroungSelf.messagesDictionary.values)
                        
                        self?.userAllMessage.sorted(by: { (message1, message2) -> Bool in
                            return Int(message1.timestamp!) > Int(message2.timestamp!)
                        })
                        
                        stroungSelf.messageListTableView.reloadData()
                    }
            }
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
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAllMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "controllerMessage", for: indexPath) as? ControllerMessageCell {
            let cellData = userAllMessage[indexPath.row]
            cell.selectionStyle = .none
            let userId = Auth.auth().currentUser?.uid
            
            cell.taskNameLabel.text = cellData.taskTitle
            
            if cellData.text == nil && cellData.imageUrl != nil {
                cell.messageLabel.text = "對方傳送圖片..."
            } else {
                cell.messageLabel.text = cellData.text
            }
            
            if let seconds = cellData.timestamp {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm a"
                cell.dateLabel.text = dateFormater.string(from: timestampDate)
            }
            
            // downloadUserPhoto(userID: cellData.fromId!, finder: "UserPhoto") { (url) in
            //                    cell.userPhoto.sd_setImage(with: url, completed: nil)
            //                }
            cell.taskType.text = cellData.taskType
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellData = userAllMessage[indexPath.row]
        getUserTaskInfo(cellData: cellData)
        tableView.allowsSelection = false
    }
    
    func getUserTaskInfo(cellData: Message) {
        
        myRef.child("Task").queryOrderedByKey().queryEqual(toValue: cellData.taskKey!).observeSingleEvent(of: .value) { (snapshot) in
            
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
                                        taskKey: keyValue, agree: agree, requestKey: nil,
                                        requestTaskKey: nil, address: nil)
                self.taskInfo.append(task)
            }
        }
        
        myRef.child("UserData").queryOrderedByKey()
            .queryEqual(toValue: cellData.taskOwnerId!)
            .observeSingleEvent(of: .value) { (snapshot) in
                
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
                    self.taskOwnerInfo.append(extractedExpr)
                }
                
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.taskInfo = self.taskInfo.last
                chatLogController.userInfo = self.taskOwnerInfo.last
                chatLogController.fromTaskOwner = true
                self.navigationController?.show(chatLogController, sender: nil)
        }
    }
}
