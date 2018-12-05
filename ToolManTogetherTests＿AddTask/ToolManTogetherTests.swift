//
//  ToolManTogetherTests_AddTask.swift
//  ToolManTogetherTests＿AddTask
//
//  Created by Spoke on 2018/12/5.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import XCTest
@testable import ToolManTogether

class ToolManTogetherTests: XCTestCase {
    
    var addUnderTest: AddTaskViewController!

    override func setUp() {
        super.setUp()
        
        // 創造一個 System Under Test
        addUnderTest = AddTaskViewController()
        addUnderTest.addTask(sender)
    }

    override func tearDown() {

    }

    func testExample() {

    }

    func testPerformanceExample() {
        self.measure {
        }
    }

}
