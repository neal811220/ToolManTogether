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

    override func viewDidLoad() {
        super.viewDidLoad()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        myRef = Database.database().reference()
        
        let messageListNib = UINib(nibName: "controllerMessage", bundle: nil)
        self.messageListTableView.register(messageListNib, forCellReuseIdentifier: "controllerMessage")
        
        getMessageListData()

    }
    
    func getMessageListData() {
        
        let userId = Auth.auth().currentUser?.uid
        myRef.child("userAllTask").queryOrderedByKey()
            .queryEqual(toValue: userId!)
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                
                guard let data = snapshot.value as? NSDictionary else { return }
                for value in data.allValues {
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let taskKey = dictionary["taskKey"] as? String else { return }
                    
                    let data = MessageTaskKey(taskKey: taskKey)
                    self?.userAllTaskKey.append(data)
                }
        }
    }
    
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "controllerMessage", for: indexPath) as? ControllerMessageCell {
            
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
