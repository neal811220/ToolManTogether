//
//  TabBarViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

private enum Tab {
    case home
    case addTask
    
    func controller() -> UIViewController {
      
        switch self {
            
        case .home:
            return UIStoryboard.homeStoryboard().instantiateInitialViewController()!
            
        case .addTask:
            return UIStoryboard.addStoryboard().instantiateInitialViewController()!
        }
      
    }
    
    func image() -> UIImage {
        switch self {
            
        case.home: return #imageLiteral(resourceName: "tab_main_normal")
        case .addTask: return #imageLiteral(resourceName: "add")
            
        }
    }
}


class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTab()
    }
    
    private func setTab() {
        
        tabBar.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        var controllers: [UIViewController] = []
        
        let tabs: [Tab] = [.home, .addTask]
        
        for myTab in tabs {
            let controller = myTab.controller()
            
            let item = UITabBarItem(title: nil, image: myTab.image(), selectedImage: nil)
            
//            item.imageInsets = UIEdgeInsets(top: 8,
//                                            left: 0,
//                                            bottom: -6,
//                                            right: 0)
            controller.tabBarItem = item
            controllers.append(controller)
        }
        setViewControllers(controllers, animated: true)
    }

}
