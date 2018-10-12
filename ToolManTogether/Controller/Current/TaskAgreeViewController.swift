//
//  TaskAgreeViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage

class TaskAgreeViewController: UIViewController {
    
    @IBOutlet weak var taskAgreeTableView: UITableView!
    @IBOutlet weak var popUpScoreView: UIView!
    @IBOutlet weak var popUpScoreHeight: NSLayoutConstraint!
    
    var userInfo: [RequestUserInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "任務進行中"

        taskAgreeTableView.delegate = self
        taskAgreeTableView.dataSource = self
        
        let taskAgreenib = UINib(nibName: "ProfileCell", bundle: nil)
        self.taskAgreeTableView.register(taskAgreenib, forCellReuseIdentifier: "profileTitle")
        
        let taskInfoNib = UINib(nibName: "TaskAgreeInfoCell", bundle: nil)
        self.taskAgreeTableView.register(taskInfoNib, forCellReuseIdentifier: "taskInfoCell")
        
        let taskMapNib = UINib(nibName: "TaskAgreeMapCell", bundle: nil)
        self.taskAgreeTableView.register(taskMapNib, forCellReuseIdentifier: "taskAgreeMapCell")
        
        let servcedNib = UINib(nibName: "ProfileServcedListCell", bundle: nil)
        self.taskAgreeTableView.register(servcedNib, forCellReuseIdentifier: "servcedList")
        
        let goodCitizenNib = UINib(nibName: "GoodCitizenCardCell", bundle: nil)
        self.taskAgreeTableView.register(goodCitizenNib, forCellReuseIdentifier: "goodCitizen")
        
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
    
    func showAlert(title: String = "無法撥打電話", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    class func profileDetailDataForTask(_ data: [RequestUserInfo]) -> TaskAgreeViewController {
        let storyBoard = UIStoryboard(name: "TaskAgree", bundle: nil)

        let viewController = storyBoard.instantiateViewController(withIdentifier: "taskAgreeVC") as? TaskAgreeViewController

        if let viewController = viewController {
            viewController.userInfo = data
        }
        return viewController!
    }
    
}
extension TaskAgreeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileTitle", for: indexPath) as? ProfileCell {
                let cellData = userInfo[indexPath.row]
                cell.userName.text = cellData.fbName
                cell.userEmail.text = cellData.fbEmail
                
                let userID = cellData.userID
                self.downloadUserPhoto(userID: userID, finder: "UserPhoto") { (url) in
                    cell.userPhoto.sd_setImage(with: url, completed: nil)
                }
                
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "taskInfoCell", for: indexPath) as? TaskAgreeInfoCell {
                let cellData = userInfo[indexPath.row]
                cell.contentTxtView.text = cellData.aboutUser
                cell.callBtnDelegate = self
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "goodCitizen", for: indexPath) as? GoodCitizenCardCell {
                
                let cellData = userInfo[indexPath.row]
                let userID = cellData.userID
                self.downloadUserPhoto(userID: userID, finder: "GoodCitizen") { (url) in
                    cell.imagePicker.sd_setImage(with: url, completed: nil)
                }
                return cell
            }
        }
        return UITableViewCell()
    }

}

extension TaskAgreeViewController: CallBtnTapped {

    func callBtnTapped(_ send: UIButton) {
        
        if let phone = userInfo.last?.userPhone {
            
            if let url = URL(string: "tel://\(phone)") {
                UIApplication.shared.open(url)
            }else {
                showAlert(content: "無法撥打電話，請稍候再嘗試")
            }
            
        } else {
            showAlert(content: "無法撥打電話，請稍候再嘗試")
        }
    }
    
    func messageBtnTapped(_ send: UIButton) {
        
        if let id = userInfo.last?.fbID {
            if let url = URL(string: "fb-messenger://user-thread/\(id)") {
                
                // Attempt to open in Messenger App first
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (success) in
                    
                    if success == false {
                        // Messenger is not installed. Open in browser instead.
                        let url = URL(string: "https://m.me/\(id)")
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!)
                        }
                    }
                })
            }
        }
    }
}
