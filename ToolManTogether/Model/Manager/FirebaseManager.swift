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
    
    func updateRequest(
        path: String,
        selectData: UserTaskInfo,
        selectDataKey: String,
        autoId: String?,
        userId: String?
        ) {
        
        self.myRef.child(path).queryOrdered(byChild: "checkTask").queryEqual(toValue: selectData.checkTask).observeSingleEvent(of: .value) { (snapshot) in
            
            self.myRef.child(path).child(autoId!).setValue([
                    "Title": selectData.title,
                    "Content": selectData.content,
                    "UserName": selectData.userName,
                    "UserID": selectData.userID,
                    "Type": selectData.type,
                    "Price": selectData.price,
                    "Lat": selectData.taskLat,
                    "Lon": selectData.taskLon,
                    "checkTask": selectData.checkTask,
                    "distance": selectData.distance,
                    "Time": Double(Date().millisecondsSince1970),
                    "ownerID": selectData.ownerID,
                    "OwnerAgree": "waiting",
                    "address": selectData.address])
            self.myRef.child("userAllTask").child(userId!).child(selectDataKey).updateChildValues([
                    "taskKey": selectDataKey,
                    "taskTitle": selectData.title,
                    "taskOwnerName": selectData.userName,
                    "taskOwnerId": selectData.ownerID])
        }
        
    }
    
    func updateRequestDataToOwner(
        taskKey: String,
        distance: Double?,
        requestTaskID: String
    ) {
        
        guard let distance = distance else { return }
        self.myRef.child("Task").child(taskKey).child("RequestUser").child(autoID).updateChildValues([
            "userID": userID,
            "distance": distance,
            "agree": false,
            "RequestTaskID": requestTaskID,
            "taskKey": taskKey])
        
            self.myRef.child("RequestTask").child(requestTaskID).updateChildValues([
            "requestUserKey": autoID,
            "taskKey": taskKey])
    }
}
