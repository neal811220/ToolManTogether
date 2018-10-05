//
//  AddTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class AddTaskViewController: UIViewController {
    
    // Outlate
    @IBOutlet weak var addTaskTableView: UITableView!
    @IBOutlet weak var addTaskBgView: UIView!
    @IBOutlet weak var addTaskButton: UIButton!
    
    var titleTxt: String?
    var contentTxt: String?
    var taskType: String?
    var priceTxt: String?
    var homeVC = HomeViewController()
    var locationManager = CLLocationManager()
    var myRef: DatabaseReference!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTaskTableView.rowHeight = 100
        addTaskTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTableView.delegate = self
        addTaskTableView.dataSource = self
        
        let infoNib = UINib(nibName: "AddTaskInfoCell", bundle: nil)
        self.addTaskTableView.register(infoNib, forCellReuseIdentifier: "titleAndContent")
        
        let titleNib = UINib(nibName: "AddTaskTitleCell", bundle: nil)
        self.addTaskTableView.register(titleNib, forCellReuseIdentifier: "title")
        
        let contentNib = UINib(nibName: "AddTaskContentCell", bundle: nil)
        self.addTaskTableView.register(contentNib, forCellReuseIdentifier: "Content")
        
        let typeNib = UINib(nibName: "AddTaskTypeCell", bundle: nil)
        self.addTaskTableView.register(typeNib, forCellReuseIdentifier: "TypeTableVIewCell")
        
        myRef = Database.database().reference()
        
        addTaskBgView.layer.cornerRadius = 23
        
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        guard let title = titleTxt else {
            showAlert(content: "Title is required")
            return
        }
        guard let content = contentTxt else {
            showAlert(content: "Content is required")
            return
        }
        guard let taskType = taskType else {
            showAlert(content: "Please select the Type")
            return
        }
        guard let userCoordinate = homeVC.locationManager.location?.coordinate else {
            showAlert(title: "Location is something wrong", content: "Please try again later")
            return
        }
        guard let price = priceTxt else {
            showAlert(content: "Price is required")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let autoID = myRef.childByAutoId().key
        guard let userName = Auth.auth().currentUser?.displayName else { return }

        myRef.child("Task").child(autoID!).setValue([
            "Title": title,
            "Content": content,
            "Type": taskType,
            "Price": price,
            "UserID": userID,
            "UserName": userName,
            "lat": userCoordinate.latitude,
            "lon": userCoordinate.longitude,
            "searchAnnotation": "\(userCoordinate.latitude)_\(userCoordinate.longitude)",
            "Time": Double(Date().millisecondsSince1970)])
        
        NotificationCenter.default.post(name: .addTask, object: nil)
    }
    
    func showAlert(title: String = "Incomplete Information", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? AddTaskTitleCell {
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.titleCompletion = { [weak self] (result) in
                    self?.titleTxt = result
                }
                return cell
            }
            
        } else if indexPath.section == 2 {
        
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "TypeTableVIewCell", for: indexPath) as? AddTaskTypeCell {
                cell.typeTitleCompletion = { [weak self] (result) in
                    self?.taskType = result
                }
                return cell
            }
            
            
        } else if indexPath.section == 3 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.textField.placeholder = "價格"
                cell.titleCompletion = { [weak self] (result) in
                    self?.priceTxt = result
                }
                return cell
            }
        } else if indexPath.section == 4 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "Content", for: indexPath) as? AddTaskContentCell {
                cell.contentTextView.text = "Content"
                cell.contentTextView.textColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8039215686, alpha: 1)
                cell.contentTextView.delegate = self
                cell.backgroundColor = .red
                return cell
            }
        
        }
        return UITableViewCell()
    }
}

extension AddTaskViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Content" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
//            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Content"
            textView.textColor = UIColor.lightGray
        } else {
            contentTxt = textView.text
        }
    }
}

extension Notification.Name {
    static let addTask = Notification.Name("addTask")
}

