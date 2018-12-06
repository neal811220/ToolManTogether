//
//  TestingAddTaskTests.swift
//  TestingAddTaskTests
//
//  Created by Spoke on 2018/12/6.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import XCTest
import KeychainSwift
@testable import ToolManTogether


class TestInputDataIsComplete: XCTestCase {
    
    var addTaskVCTest: AddTaskViewController!
    
    override func setUp() {
        addTaskVCTest = (UIStoryboard(name: "addTask", bundle: nil).instantiateViewController(withIdentifier: "addTaskVC") as? AddTaskViewController)
    }

    override func tearDown() {
        addTaskVCTest = nil
        super.tearDown()
    }

    func testExample() {

    }
    
    // 測試模型
    func testInputValue() {
        
        // given 給定一個值
        addTaskVCTest.titleTxt = "燈泡壞掉"
        
        // when 要被執行的代碼
        let check = addTaskVCTest.checkInput()
        
        // than 期待的結果
        XCTAssertEqual(check, false, "檢查錯誤，資料輸入不完整")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
