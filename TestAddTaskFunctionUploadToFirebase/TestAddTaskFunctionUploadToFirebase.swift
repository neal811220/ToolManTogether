//
//  TestAddTaskFunctionUploadToFirebase.swift
//  TestAddTaskFunctionUploadToFirebase
//
//  Created by Spoke on 2018/12/8.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import XCTest
@testable import ToolManTogether

class TestAddTaskFunctionUploadToFirebase: XCTestCase {

    var addTaskVCTest: AddTaskViewController!
    var mockFirebaseManager: MockFirebaseManager!
    
    override func setUp() {
        super.setUp()
        addTaskVCTest = (UIStoryboard(name: "addTask", bundle: nil).instantiateViewController(withIdentifier: "addTaskVC") as? AddTaskViewController)
        mockFirebaseManager = MockFirebaseManager()
    }

    override func tearDown() {
        addTaskVCTest = nil
        mockFirebaseManager = nil
        super.tearDown()
    }

    func testExample() {
    }

    func testPerformanceExample() {
        self.measure {
        }
    }

    func testAddTaskFunctionConnectToFirebase() {
        
        // given 給定一個值
        setInputData()
        
        // when 要被執行的代碼
        mockFirebaseManager.updateTask(path: "Task", addTaskvc: addTaskVCTest)
        
        // than 期待的結果
        XCTAssertEqual(mockFirebaseManager.connect, true, "連接失敗")
        
    }
    
    func setInputData() {
        addTaskVCTest.titleTxt = "testing"
        addTaskVCTest.priceTxt = "testing"
        addTaskVCTest.contentTxt = "testing"
        addTaskVCTest.taskType = "testing"
    }

}

class MockFirebaseManager: FirebaseManager {
    
    var connect = false
    
    override func updateTask(path: String, addTaskvc: AddTaskViewController) {
        connect = true
    }
}
