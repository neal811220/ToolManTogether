//
//  Firebase.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/12/4.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseManager {
    
    var myRef: DatabaseReference!
    
    init() {
        myRef = Database.database().reference()
    }
    
    func taskAdd(
        path: String,
        event: FirebaseEventType,
        successValue: @escaping (_ key: String, _ value: Any) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        myRef.child(path).observeSingleEvent(of: event.eventType(), with: { snapshot in
            
            let key = snapshot.key
            guard let value = snapshot.value else {
                failure(FirebaseError.snapshotFail)
                return
            }
            successValue(key, value)
        })
    }
}

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
