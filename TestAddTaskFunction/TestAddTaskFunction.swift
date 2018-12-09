//
//  TestAddTaskFunction.swift
//  TestAddTaskFunction
//
//  Created by Spoke on 2018/12/8.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import XCTest
import KeychainSwift
@testable import ToolManTogether

class TestAddTaskFunction: XCTestCase {
    var addTaskVCTest: AddTaskViewController!
    var mockKeychain: MockKeychain!
    
    override func setUp() {
        super.setUp()
        addTaskVCTest = (UIStoryboard(name: "addTask", bundle: nil).instantiateViewController(withIdentifier: "addTaskVC") as? AddTaskViewController)
        
        mockKeychain = MockKeychain()
        addTaskVCTest.keychain = mockKeychain
    }
    
    override func tearDown() {
        addTaskVCTest = nil
        mockKeychain = nil
        super.tearDown()
    }
    
    func testExample() {
    }
    
    func testInputValue() {
        
        // given 給定一個值
        addTaskVCTest.titleTxt = "燈泡壞掉"
        
        // when 要被執行的代碼
        let check = addTaskVCTest.checkInput()
        
        // than 期待的結果
        XCTAssertEqual(check, false, "資料輸入不完整")
    }
    
    func testGuestMode() {
        
        // given 給定一個值
        
        
    }
    
    
    
    func testPerformanceExample() {
        self.measure {
        }
    }
}

class MockKeychain: KeychainSwift {
    
    var guest = true
    
    override func get(_ key: String) -> String? {
        if key == "guest" {
            return "guest"
        }
        guest = false
        return "logIn"
    }
}
