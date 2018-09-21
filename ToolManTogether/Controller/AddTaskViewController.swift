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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTableView.delegate = self
        addTaskTableView.dataSource = self
        
        let infoNib = UINib(nibName: "AddTaskInfoCell", bundle: nil)
        self.addTaskTableView.register(infoNib, forCellReuseIdentifier: "titleAndContent")
        
        let titleNib = UINib(nibName: "AddTaskTitleCell", bundle: nil)
        self.addTaskTableView.register(titleNib, forCellReuseIdentifier: "title")
        
    
        
        

    }
    


}

extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        }

        return UITableViewCell()
    }
    
}
