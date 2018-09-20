//
//  UserManager.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

class UserManager {
    
    static let fbUser = UserManager()
    
    let fbUserDefault: UserDefaults = UserDefaults.standard
    
    func getUserToken() -> String? {
        
        guard let userToken = fbUserDefault.object(forKey: "token") as? String else {
            return nil
        }
        return userToken
    }
}
