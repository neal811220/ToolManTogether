//
//  AddTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var addTaskTableView: UITableView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        addTaskTableView.estimatedRowHeight = 155
//        addTaskTableView.rowHeight = UITableView.automaticDimension

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
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                return cell
            }
            
        } else if indexPath.section == 2 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Content", for: indexPath) as? AddTaskContentCell {
                cell.contentTextView.text = "Content"
                cell.contentTextView.textColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8039215686, alpha: 1)
                cell.contentTextView.delegate = self
                return cell
            }
        } else if indexPath.section == 3 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeTableVIewCell", for: indexPath) as? AddTaskTypeCell {

                return cell
            }
        } else if indexPath.section == 4 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.textView.placeholder = "Price"
                return cell
            }
        }

        return UITableViewCell()
    }
    
}

extension AddTaskViewController: UITextViewDelegate {
    
//    func textViewDidChange(textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textView.frame = newFrame
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Content" {
            textView.text = ""
            textView.textColor = UIColor.black
//            textView.font = UIFont(name: "Avenir Next", size: 18.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Content"
            textView.textColor = UIColor.lightGray
            
        }
    }
}

