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

class SearchTaskViewController: UIViewController {
    
    @IBOutlet weak var searchTaskTableVIew: UITableView!
    var photoURL: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchNib = UINib(nibName: "searchTaskCell", bundle: nil)
        self.searchTaskTableVIew.register(searchNib, forCellReuseIdentifier: "searchTask")
        
        searchTaskTableVIew.delegate = self
        searchTaskTableVIew.dataSource = self
        
    }
    
//    func updataTaskInfoDetail() {
//
//        let storageRef = Storage.storage().reference()
//
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//
//        storageRef.child("UserPhoto").child(userId).downloadURL(completion: { (url, error) in
//
//            if let error = error {
//                print("User photo download Fail: \(error.localizedDescription)")
//            }
//
//            if let url = url {
//                print("url \(url)")
//                photoURL.append(<#T##newElement: URL##URL#>)
//
//                self.pullUpDetailView.userPhoto.sd_setImage(with: url, completed: nil)
//            }
//        })
//
//    }


}

extension SearchTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchTask", for: indexPath) as? SearchTaskCell {
            cell.searchTaskView.userPhoto.image = UIImage(named: "userImage_Spock")
            cell.searchTaskView.sendButton.addTarget(self, action: #selector(requestBtnPressed), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
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
