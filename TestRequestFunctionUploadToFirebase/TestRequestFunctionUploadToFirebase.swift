//
//  TestRequestFunctionUploadToFirebase.swift
//  TestRequestFunctionUploadToFirebase
//
//  Created by Spoke on 2018/12/9.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import XCTest
@testable import ToolManTogether

class TestRequestFunctionUploadToFirebase: XCTestCase {
    
    var homeVCTest: HomeViewController!
    var mockFirebaseManager: MockFirebaseManager!
    var fakeData: UserTaskInfo?

    override func setUp() {
        super.setUp()
        homeVCTest = (UIStoryboard(name: "home", bundle: nil).instantiateViewController(withIdentifier: "homeVC") as? HomeViewController)
        mockFirebaseManager = MockFirebaseManager()
    }

    override func tearDown() {
        homeVCTest = nil
        mockFirebaseManager = nil
        super.tearDown()
    }

    func testExample() {
    }
    
    func testRequestFunctionConnectToFirebase() {
        
        // given 給定一個值
        setInputData()
        
        // when
        mockFirebaseManager.updateRequest(path: "RequestTask", selectData: fakeData!, selectDataKey: "testing", autoId: "testing", userId: "testing")
        
        XCTAssertEqual(mockFirebaseManager.connect, true, "連線失敗")
    }

    func testPerformanceExample() {
        self.measure {
        }
    }
    
    func setInputData()  {
        fakeData = UserTaskInfo(userID: "testing", userName: "testing",
                                title: "testing", content: "testing",
                                type: "testing", price: "testing",
                                taskLat: 10.00, taskLon: 10.00,
                                checkTask: "testing", distance: 10.00,
                                time: 10, ownerID: "testing",
                                ownAgree: "false", taskKey: "testing",
                                agree: false, requestKey: "testing",
                                requestTaskKey: "testing",
                                address: "testing")
    }

}

class MockFirebaseManager: FirebaseManager {
    
    var connect = false
    
    override func updateRequest(path: String, selectData: UserTaskInfo, selectDataKey: String, autoId: String?, userId: String?) {
        connect = true
    }
    
}
