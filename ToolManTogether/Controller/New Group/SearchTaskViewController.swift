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
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("RequestTask")
            .queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    print(data.allKeys)
                    guard let dictionary = value as? [String: Any] else { return }
                    print(dictionary)
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
                    let task = UserTaskInfo(userID: userID,
                                            userName: userName,
                                            title: title,
                                            content: content,
                                            type: type, price: price,
                                            taskLat: taskLat, taskLon: taskLon,
                                            checkTask: checkTask, distance: distance, time: time, ownerID: taskOwner)
                    
                    
//                    if self.selectTask.count != 0 {
//                        var result = false
//                        for eachTask in self.selectTask {
//                            if (task.taskLat + task.taskLon) == (eachTask.taskLat + eachTask.taskLon) {
//                                result = true
//                            }
//                        }
//                        if result == false {
//                            self.selectTask.append(task)
//                        }
//
//                    } else {
//                        self.selectTask.append(task)
//                    }
                    
                    self.selectTask.append(task)
                    self.selectTask.sort(by: { $0.time! > $1.time!})
                }

                self.searchTaskTableVIew.reloadData()
                
            }) { (error) in
                print(error.localizedDescription)
        }
    }
}

extension SearchTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchTask", for: indexPath) as? SearchTaskCell {
            
            let cellData = selectTask[indexPath.row]
            
            cell.searchTaskView.taskTitleLabel.text = cellData.title
            cell.searchTaskView.userName.text = cellData.userName
            cell.searchTaskView.taskContentTxtView.text = cellData.content
            cell.searchTaskView.distanceLabel.text = "\(cellData.distance!)km"
            cell.searchTaskView.typeLabel.text = cellData.type
            cell.searchTaskView.priceLabel.text = cellData.price
            if let ownerID = cellData.ownerID {
                updataTaskUserPhoto(userID: ownerID) { (url) in
                    if url == url {
                        cell.searchTaskView.userPhoto.sd_setImage(with: url, completed: nil)
                    }
                }
            } else {
                cell.searchTaskView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
            }

            cell.searchTaskView.sendButton.addTarget(self, action: #selector(requestBtnPressed), for: .touchUpInside)
            
            return cell
        }
        return UITableViewCell()
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
