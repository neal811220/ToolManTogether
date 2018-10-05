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
                        guard let aboutUser = dictionary["AboutUser"] as? String else { return }
                        guard let fbEmail = dictionary["FBEmail"] as? String else { return }
                        guard let fbID = dictionary["FBID"] as? String else { return }
                        guard let fbName = dictionary["FBName"] as? String else { return }
                        guard let userPhone = dictionary["UserPhone"] as? String else { return }
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
                cell.scrollTaslDelegate = self
                cell.selectionStyle = .none
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

extension HistoryTaskViewController: TableViewCellDelegate {

    func tableViewCellDidTapAgreeBtn(_ cell: RequestToolsTableViewCell) {

        
        
    }
}

extension HistoryTaskViewController: ScrollTask {
    
    func didScrollTask(_ cell: String) {
        
        self.requestTools.removeAll()
        self.toolsInfo.removeAll()
        self.historyTableView.reloadData()

        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("Task").queryOrdered(byChild: "searchAnnotation")
            .queryEqual(toValue: cell)
            .observeSingleEvent(of: .value) { (snapshot) in
            
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let requestUser = dictionary["RequestUser"] as? [String: Any] else { return }
                    guard let distance = requestUser["distance"] as? Double else { return }
                    guard let userID = requestUser["userID"] as? String else { return }
                    guard let agree = requestUser["agree"] as? Bool else { return }
                    
                    let requestData = RequestUser(agree: agree, distance: distance, userID: userID)
                    
                    self.requestTools.append(requestData)
                    self.searchToos()
                    
                }
        }
    }
}
