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

    
}

extension HistoryTaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 10
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "requestedCell", for: indexPath) as? RequestCell {
                cell.scrollTaslDelegate = self
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "requestTools", for: indexPath) as? RequestToolsTableViewCell {
                cell.delegate = self
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
}

extension HistoryTaskViewController: TableViewCellDelegate {
    func tableViewCellDidTapAgreeBtn(_ cell: RequestToolsTableViewCell) {
        
        guard let selectIndex = self.historyTableView.indexPath(for: cell) else {
            return
        }
        
        print(selectIndex)
        
        let storyBoard = UIStoryboard(name: "TaskAgree", bundle: nil)
        
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "taskAgreeVC") as? TaskAgreeViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension HistoryTaskViewController: ScrollTask {
    
    func didScrollTask(_ cell: String) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        myRef.child("Task").queryOrdered(byChild: "searchAnnotation")
            .queryEqual(toValue: cell)
            .observeSingleEvent(of: .value) { (snapshot) in
            
                guard let data = snapshot.value as? NSDictionary else { return }
                
                for value in data.allValues {
                    
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    guard let requestUser = dictionary["RequestUser"] as? [String: Any] else { return }
                    
                    print(requestUser)
                    
                    guard let distance = requestUser["distance"] as? Double else { return }
                    guard let userID = requestUser["userID"] as? String else { return }
                    guard let agree = requestUser["agree"] as? Bool else { return }
                    
                    let requestData = RequestUser(agree: agree, distance: distance, userID: userID)
                    
                    print(requestData)
                    
                    
                    
                    
                }
        }
    }
}
