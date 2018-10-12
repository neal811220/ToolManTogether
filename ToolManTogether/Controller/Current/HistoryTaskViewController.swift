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
import FirebaseMessaging

class HistoryTaskViewController: UIViewController {
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgLabel: UILabel!
    
    var myRef: DatabaseReference!
    var requestTools: [RequestUser] = []
    var toolsInfo: [RequestUserInfo] = []
    var selectToosData: RequestUser!
    
    var agreeToos: RequestUser?
    var agreeToolsInfo: RequestUserInfo?
    var client = HTTPClient(configuration: .default)
    
    var refreshController: UIRefreshControl!
    var scrollViewDefine: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        refreshController = UIRefreshControl()
        refreshController.attributedTitle = NSAttributedString(string: "資料讀取中...")

        historyTableView.addSubview(refreshController)
        refreshController.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        
        let typeNib = UINib(nibName: "RequestCell", bundle: nil)
        self.historyTableView.register(typeNib, forCellReuseIdentifier: "requestedCell")
        
        let toosNib = UINib(nibName: "RequestToolsTableViewCell", bundle: nil)
        self.historyTableView.register(toosNib, forCellReuseIdentifier: "requestTools")
        
        myRef = Database.database().reference()
        
        let noTaskNotification = Notification.Name("noTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.notask), name: noTaskNotification, object: nil)
        
        let hasTaskNotification = Notification.Name("hasTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.hastask), name: hasTaskNotification, object: nil)
        
    }
    
    @objc func notask() {
        bgView.isHidden = false
        bgLabel.isHidden = false
    }
    
    @objc func hastask() {
        bgView.isHidden = true
        bgLabel.isHidden = true

    }
    
    @objc func loadData() {
        
        refreshController.beginRefreshing()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.historyTableView.contentOffset = CGPoint(x: 0, y: -self.refreshController.bounds.height)
        }) { (finish) in
            if self.scrollViewDefine != nil {
                self.didScrollTask(self.scrollViewDefine)
            }
            self.refreshController.endRefreshing()
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
    
    func searchToos() {
        
        self.toolsInfo.removeAll()
        self.historyTableView.reloadData()
        
        for data in requestTools {
            
            myRef.child("UserData").queryOrderedByKey()
                .queryEqual(toValue: data.userID)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    self.toolsInfo.removeAll()
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
                        
                        self.toolsInfo.append(toolsInfo)
                        self.historyTableView.reloadData()
                    }
            }
        }
    }
    
    func sendNotification(title: String = "", content: String, toToken: String) {
        
        if let token = Messaging.messaging().fcmToken {
            client.sendNotification(fromToken: token, toToken: toToken, title: title, content: content) { (bool, error) in
                print(bool)
                print(error)
            }
        }
    }

    func confirm() {
        
        let requestTaskKey = self.selectToosData.requestTaskID
        let taskOwnerKey = self.selectToosData.taskOwnerID
        let taskRequestUserKey = self.selectToosData.requestKey
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        
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
                
                self.didScrollTask(self.scrollViewDefine)
                
                if let toolsToken = self.agreeToolsInfo?.remoteToken {
                    self.sendNotification(content: "任務已被\(currentUser)同意，趕快來查看", toToken: toolsToken)
                }
                
            } else {
                
                self.myRef.child("RequestTask").child(value.requestTaskID).updateChildValues([
                    "OwnerAgree": "disAgree"])
                
                for disAgreeRemoteToken in self.toolsInfo {
                    if disAgreeRemoteToken.remoteToken != self.agreeToolsInfo!.remoteToken {
                            self.sendNotification(content: "任務已被\(currentUser)拒絕！", toToken: disAgreeRemoteToken.remoteToken!)
                    }
                }
            }
        }
        
        self.requestTools.removeAll()
        self.toolsInfo.removeAll()
        self.historyTableView.reloadData()

        guard let agreeToos = self.agreeToos, let toolsInfo = self.agreeToolsInfo else { return }
        self.requestTools.append(agreeToos)
        self.toolsInfo.append(toolsInfo)
    
        self.historyTableView.reloadData()
    }
    
    @objc func showAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們會儘快處理", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: nil)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        personAlertController.addAction(reportAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
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
                    cell.moreBtn.isHidden = false
                    cell.moreBtn.addTarget(self, action: #selector(self.showAlert), for: .touchUpInside)
                } else {
                    cell.agreeButton.isHidden = false
                    cell.moreBtn.isHidden = true
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
        
        let viewController = TaskAgreeViewController.profileDetailDataForTask(toolsInfo)
            self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HistoryTaskViewController: TableViewCellDelegate {

    func tableViewCellDidTapAgreeBtn(_ cell: RequestToolsTableViewCell) {
        
            let alert = UIAlertController(title: "確認新增？", message: "將新增對方為工具人", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default) { (void) in
                self.confirm()
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        
            guard let tappedIndex = self.historyTableView.indexPath(for: cell) else {
                return
            }
            
            self.selectToosData = requestTools[tappedIndex.row]
            
            self.agreeToos = self.requestTools[tappedIndex.row]
            self.agreeToolsInfo = self.toolsInfo[tappedIndex.row]
    }
    
}

extension HistoryTaskViewController: ScrollTask {
    
    func didScrollTask(_ cell: String) {
        
        self.requestTools.removeAll()
        self.toolsInfo.removeAll()
        self.historyTableView.reloadData()
        self.scrollViewDefine = cell

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
                        print(requestUserData.value)
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
                            self.toolsInfo.removeAll()
                            self.requestTools.append(requestData)
//                            self.searchToos()
//                            return
                        } else {
                            self.requestTools.append(requestData)
//                            self.searchToos()
                        }

                    }
                    self.searchToos()

                }
        }
    }
}

extension HistoryTaskViewController: btnPressed {

    func btnPressed(_ send: TaskDetailInfoView) {
        
        print(requestTools)
        for requestTask in requestTools {
                self.myRef.child("RequestTask").child(requestTask.requestTaskID).updateChildValues([
                    "OwnerAgree": "delete"])
        }
    }
}

extension Notification.Name {
    static let agreeToos = Notification.Name("agreeToos")
}
