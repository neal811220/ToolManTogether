//
//  HistoryTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class HistoryTaskViewController: UIViewController {
    
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        let typeNib = UINib(nibName: "RequestCell", bundle: nil)
        self.historyTableView.register(typeNib, forCellReuseIdentifier: "requestedCell")
        


    }
    
}

extension HistoryTaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "requestedCell", for: indexPath) as? RequestCell {
                    
            
            return cell
        }
        return UITableViewCell()
    }
    
}
