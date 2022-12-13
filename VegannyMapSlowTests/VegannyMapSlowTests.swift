//
//  VegannyMapSlowTests.swift
//  Veganny MapTests
//
//  Created by Hailey on 2022/12/8.
//

import XCTest
@testable import Veganny_Map


class VegannyMapSlowTests: XCTestCase {

    var sut: URLSession!

    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    
    // Asynchronous test: success fast, failure slow
    func testValidApiCallGetsHTTPStatusCode200() throws {
        // given
          let urlString =
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.0338,121.5646&radius=1000&keyword=vegan&language=zh-TW&key=AIzaSyCE3u5KCT169xXdo96QsrlyO6emFgyJYKo"
          let url = URL(string: urlString)!
          // 1
          let promise = expectation(description: "Status code: 200")

          // when
          let dataTask = sut.dataTask(with: url) { _, response, error in
            // then
            if let error = error {
              XCTFail("Error: \(error.localizedDescription)")
              return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
              if statusCode == 200 {
                // 2
                promise.fulfill()
              } else {
                XCTFail("Status code: \(statusCode)")
              }
            }
          }
          dataTask.resume()
          // 3
          wait(for: [promise], timeout: 5)
    }

}
