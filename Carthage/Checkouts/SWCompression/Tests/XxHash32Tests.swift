// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import XCTest
@testable import SWCompression

class XxHash32Tests: XCTestCase {

    func test1() {
        let message = ""
        let answer = 0x02cc5d05 as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test2() {
        let message = "a"
        let answer = 0x550d7456 as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test3() {
        let message = "abc"
        let answer = 0x32d153ff as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test4() {
        let message = "message digest"
        let answer = 0x7c948494 as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test5() {
        let message = "abcdefghijklmnopqrstuvwxyz"
        let answer = 0x63a14d5f as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test6() {
        let message = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let answer = 0x9c285e64 as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

    func test7() {
        let message = "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
        let answer = 0x9c05f475 as UInt32
        let hash = XxHash32.hash(data: Data(message.utf8))
        XCTAssertEqual(hash, answer)
    }

}
