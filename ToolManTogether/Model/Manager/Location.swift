//
//  Location.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/25.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import MapKit

struct UserTaskInfo {
    var userID: String
    var userName: String
    var title: String
    var content: String
    var type: String
    var price: String
    var taskLat: Double
    var taskLon: Double
    var checkTask: String?
    var distance: Double?
    var time: Int?
    var ownerID: String?
}

class TaskPin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}



