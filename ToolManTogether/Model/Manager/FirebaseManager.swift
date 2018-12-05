//
//  FirebaseManager.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/12/5.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

enum FirebaseEventType {
    
    case valueChange
    case childAdd
    
    func eventType() -> DataEventType {
        
        switch self {
        case .valueChange:
            return .value
        case .childAdd:
            return .childAdded
        }
    }
}

 enum FirebaseError: Error {
    case snapshotFail
}

class FirebaseManager {
    
    private var myRef: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var autoID = ""
    let userName = Auth.auth().currentUser?.displayName
    
    init() {
        myRef = Database.database().reference()
        autoID = myRef.childByAutoId().key!
    }
    
     func taskAdd(
        path: String,
        event: FirebaseEventType,
        successValue: @escaping (_ key: String, _ value: Any) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        myRef.child(path).observeSingleEvent(of: event.eventType(), with: { snapshot in
            
            let keys = snapshot.key
            guard let value = snapshot.value else {
                failure(FirebaseError.snapshotFail)
                return
            }
            successValue(keys, value)
        })
    }
    
     func updateTask(
        path: String,
        addTaskvc: AddTaskViewController
        ) {
        
        myRef.child(path).child(autoID).setValue([
            "Title": addTaskvc.titleTxt,
            "Content": addTaskvc.contentTxt,
            "Type": addTaskvc.taskType,
            "Price": addTaskvc.priceTxt,
            "UserID": userID,
            "UserName": userName,
            "lat": addTaskvc.customMapCenterLocation.latitude,
            "lon": addTaskvc.customMapCenterLocation.longitude,
            "searchAnnotation": "\(addTaskvc.customMapCenterLocation.latitude)_\(addTaskvc.customMapCenterLocation.longitude)",
            "Time": Double(Date().millisecondsSince1970),
            "agree": false,
            "address": addTaskvc.alertAddress])
    }
    
    func updateUserAllTask(
        path: String,
        addTaskvc: AddTaskViewController
        ) {
        
        self.myRef.child(path).child(userID!).child(autoID).updateChildValues([
            "taskKey": autoID,
            "taskTitle": addTaskvc.titleTxt,
            "taskOwnerName": userName,
            "taskownerId": userID])
    }
}
