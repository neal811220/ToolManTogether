//
//  ProfileViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var myRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        let titleNib = UINib(nibName: "ProfileCell", bundle: nil)
        self.profileTableView.register(titleNib, forCellReuseIdentifier: "profileTitle")
        
        let detailNib = UINib(nibName: "ProfileDetailCell", bundle: nil)
        self.profileTableView.register(detailNib, forCellReuseIdentifier: "profileDetail")
        
        let servcedNib = UINib(nibName: "ProfileServcedListCell", bundle: nil)
        self.profileTableView.register(servcedNib, forCellReuseIdentifier: "servcedList")
        
        let goodCitizenNib = UINib(nibName: "GoodCitizenCardCell", bundle: nil)
        self.profileTableView.register(goodCitizenNib, forCellReuseIdentifier: "goodCitizen")
        
        myRef = Database.database().reference()

    }
    
    
    
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileTitle",
                                                        for: indexPath) as? ProfileCell {
                cell.userName.text = "test"
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileDetail",
                                                        for: indexPath) as? ProfileDetailCell {
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "servcedList",
                                                        for: indexPath) as? ProfileServcedListCell {
                return cell
            }
        } else if indexPath.section == 3 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "goodCitizen",
                                                        for: indexPath) as? GoodCitizenCardCell {
                return cell
            }
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 2 {
            
            let storyBoard = UIStoryboard(name: "profileServced", bundle: nil)
            
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "servcedListVC") as? ServcedListViewController {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
}

