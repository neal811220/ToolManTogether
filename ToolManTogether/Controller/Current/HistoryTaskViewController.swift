//
//  HistoryTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage

class HistoryTaskViewController: UIViewController {
    
    @IBOutlet weak var historyTableView: UITableView!
    
    var myRef: DatabaseReference!
    var requestTools: [RequestUser] = []
    var toolsInfo: [RequestUserInfo] = []
    var selectToosData: RequestUser!
    
    var agreeToos: RequestUser?
    var agreeToolsInfo: RequestUserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        let typeNib = UINib(nibName: "RequestCell", bundle: nil)
        self.historyTableView.register(typeNib, forCellReuseIdentifier: "requestedCell")
        
        let toosNib = UINib(nibName: "RequestToolsTableViewCell", bundle: nil)
        self.historyTableView.register(toosNib, forCellReuseIdentifier: "requestTools")
        
        myRef = Database.database().reference()
        
        
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
    
    func searchToos() {
        
        toolsInfo.removeAll()
        self.historyTableView.reloadData()
        
        for data in requestTools {
            
            myRef.child("UserData").queryOrderedByKey()
                .queryEqual(toValue: data.userID)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let data = snapshot.value as? NSDictionary else { return }
                    
                    for value in data.allValues {
                        guard let dictionary = value as? [String: Any] else { return }
                        let aboutUser = dictionary["AboutUser"] as? String
                        let fbEmail = dictionary["FBEmail"] as? String
                        let fbID = dictionary["FBID"] as? String
                        let fbName = dictionary["FBName"] as? String
                        let userPhone = dictionary["UserPhone"] as? String
                        guard let userID = dictionary["UserID"] as? String else { return }
                        
                        let toolsInfo = RequestUserInfo(aboutUser: aboutUser,
                                                        fbEmail: fbEmail,
                                                        fbID: fbID,
                                                        fbName: fbName,
                                                        userPhone: userPhone, userID: userID)
                        
                        self.toolsInfo.append(toolsInfo)
                        self.historyTableView.reloadData()
                    }
            }
        }
    }
}

extension HistoryTaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return toolsInfo.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "requestedCell", for: indexPath) as? RequestCell {
                cell.scrollTaskDelegate = self
                                
                cell.toosNumTitleLabel.text = "\(toolsInfo.count)個申請"
                cell.selectionStyle = .none
                cell.scrollTaskBtnDelegate = self
                
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "requestTools", for: indexPath) as? RequestToolsTableViewCell {
                cell.delegate = self
                
                
                let cellData = toolsInfo[indexPath.row]
                let requestData = requestTools[indexPath.row]
                
                cell.userNameLabel.text = cellData.fbName
                cell.userContentTxtView.text = cellData.aboutUser
                cell.distanceLabel.text = "\(requestData.distance)"
                
                if requestData.agree == true {
                    cell.agreeButton.isHidden = true
                } else {
                    cell.agreeButton.isHidden = false
                }
                
                cell.selectionStyle = .none
                downloadUserPhoto(userID: requestData.userID, finder: "UserPhoto") { (url) in
                    cell.userPhoto.sd_setImage(with: url, completed: nil)
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard(name: "TaskAgree", bundle: nil)

        let viewController = TaskAgreeViewController.profileDetailDataForTask(toolsInfo)
            self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HistoryTaskViewController: TableViewCellDelegate, AlertViewDelegate {

    func tableViewCellDidTapAgreeBtn(_ cell: RequestToolsTableViewCell) {

        if let alertView = Bundle.main.loadNibNamed("ScoreSendView", owner: nil, options: nil)?.first as? ScoreSendView {
            alertView.delegate = self
            alertView.tag = 101
            self.historyTableView.addSubview(alertView)
            
            guard let tappedIndex = self.historyTableView.indexPath(for: cell) else {
                return
            }
            
            self.selectToosData = requestTools[tappedIndex.row]
            
            self.agreeToos = self.requestTools[tappedIndex.row]
            self.agreeToolsInfo = self.toolsInfo[tappedIndex.row]

//            myRef.child("Task").child(selectToosData.taskOwnerID).removeValue()
        }
    }
    
    func alertBtn(actionType: String) {
        
        guard let alertView = self.historyTableView.viewWithTag(101) as? ScoreSendView else { return }

        if actionType == "confirm" {
        
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                alertView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY)
                alertView.layer.opacity = 0
            }) { (_) -> Void in
                alertView.removeFromSuperview()
                
                let requestTaskKey = self.selectToosData.requestTaskID
                let taskOwnerKey = self.selectToosData.taskOwnerID
                let taskRequestUserKey = self.selectToosData.requestKey

                for value in self.requestTools {
                    
                    if requestTaskKey == value.requestTaskID {
                        self.myRef.child("RequestTask").child(requestTaskKey).updateChildValues([
                            "OwnerAgree": "agree"])
                    self.myRef.child("Task").child(taskOwnerKey).updateChildValues(["agree": true])
                self.myRef.child("Task").child(taskOwnerKey).child("RequestUser").child(taskRequestUserKey).updateChildValues(["agree": true])
                        
                    self.myRef.child("Task").child(taskOwnerKey).child("searchAnnotation").removeValue()
                        
                    self.myRef.child("Task").child(taskOwnerKey).child("lat").removeValue()
                    self.myRef.child("Task").child(taskOwnerKey).child("lon").removeValue()


                        
                    NotificationCenter.default.post(name: .agreeToos, object: nil)
                        
                    } else {
                        self.myRef.child("RequestTask").child(value.requestTaskID).updateChildValues([
                            "OwnerAgree": "disAgree"])
                    }
                }
                
                self.requestTools.removeAll()
                self.toolsInfo.removeAll()
                guard let agreeToos = self.agreeToos, let toolsInfo = self.agreeToolsInfo else { return }
                self.requestTools.append(agreeToos)
                self.toolsInfo.append(toolsInfo)
                self.historyTableView.reloadData()
            }
            
        }else if actionType == "cancel" {
            alertView.removeFromSuperview()
        }
    }
}

extension HistoryTaskViewController: ScrollTask {
    
    func didScrollTask(_ cell: String) {
        
        self.requestTools.removeAll()
        self.toolsInfo.removeAll()
        self.historyTableView.reloadData()

        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("Task").queryOrderedByKey()
            .queryEqual(toValue: cell)
            .observeSingleEvent(of: .value) { (snapshot) in
            
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let requestUser = dictionary["RequestUser"] as? NSDictionary else { return }
                    
                    for requestUserData in requestUser {
                        
                        guard let keyValue = requestUserData.key as? String else { return }
                        guard let requestDictionary = requestUserData.value as? [String: Any] else { return }
                        print(requestDictionary)
                        guard let distance = requestDictionary["distance"] as? Double else { return }
                        guard let userID = requestDictionary["userID"] as? String else { return }
                        guard let agree = requestDictionary["agree"] as? Bool else { return }
                        guard let requestTaskID = requestDictionary["RequestTaskID"] as? String else { return }
                        guard let taskOwnerID = requestDictionary["taskKey"] as? String else { return }
                        
                         let requestData = RequestUser(agree: agree, distance: distance, userID: userID, requestTaskID: requestTaskID, taskOwnerID: taskOwnerID, requestKey: keyValue)
                        
                        if agree == true {
                           self.requestTools.removeAll()
                            self.requestTools.append(requestData)
                        } else {
                            self.requestTools.append(requestData)
                        }
                        
                    }
                        self.searchToos()
                }
        }
    }
}

extension HistoryTaskViewController: btnPressed {
    
    func btnPressed(_ send: TaskDetailInfoView) {
        send.sendButton.setTitle("YAA", for: .normal)
    }
}

extension Notification.Name {
    static let agreeToos = Notification.Name("agreeToos")
}
