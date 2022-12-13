//
//  Veganny Map Unit Test.swift
//  Veganny MapTests
//
//  Created by Hailey on 2022/12/9.
//

import XCTest
@testable import Veganny_Map

    
class VegannyMapUnitTest: XCTestCase {
    
    var sut: PublishViewController!
    
    override func setUpWithError() throws {
        sut = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "PublishViewController") as? PublishViewController
        try super.setUpWithError()

    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testCanPost() throws {
        sut.urlString = []
        XCTAssertEqual(sut.canPost(), false, "ERROR")
    }
}
