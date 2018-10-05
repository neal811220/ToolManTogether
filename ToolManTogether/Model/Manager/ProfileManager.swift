//
//  ProfileManager.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/4.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

struct ProfileManager {
    var fbEmail: String
    var fbID: String
    var fbName: String
    var aboutUser: String?
    var userPhone: String?
}

struct RequestUser {
    var agree: Bool
    var distance: Double
    var userID: String
}
