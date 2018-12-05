//
//  TaskData.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/12/4.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation

extension Task {
    
    public static func taskAdd(_ input: NSDictionary) -> Task? {
         if let type = input["Type"] as? String,
            let latData = input["lat"] as? Double,
            let lonData = input["lon"] as? Double {
            return Task(type: type, taskLat: latData, taskLon: lonData)
        }
        return nil
    }
}
