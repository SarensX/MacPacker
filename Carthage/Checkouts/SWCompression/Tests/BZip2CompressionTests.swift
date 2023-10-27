// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import SWCompression

class BZip2CompressionTests: XCTestCase {

    func answerTest(_ testName: String) throws {
        let answerData = try Constants.data(forAnswer: testName)
        let compressedData = BZip2.compress(data: answerData)
        let redecompressedData = try BZip2.decompress(data: compressedData)
        XCTAssertEqual(redecompressedData, answerData)
        if answerData.count > 0 { // Compression ratio is always bad for empty file.
            let compressionRatio = Double(answerData.count) / Double(compressedData.count)
            print(String(format: "BZip2.\(testName).compressionRatio = %.3f", compressionRatio))
        }
    }

    func stringTest(_ string: String) throws {
        let answerData = Data(string.utf8)

        let compressedData = BZip2.compress(data: answerData)

        let redecompressedData = try BZip2.decompress(data: compressedData)
        XCTAssertEqual(redecompressedData, answerData)
    }

    func testBZip2CompressStrings() throws {
        try stringTest("ban")
        try stringTest("banana")
        try stringTest("abaaba")
        try stringTest("abracadabra")
        try stringTest("cabbage")
        try stringTest("baabaabac")
        try stringTest("AAAAAAABBBBCCCD")
        try stringTest("AAAAAAA")
        try stringTest("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890")
    }

    func testBZip2CompressBytes() throws {
        var bytes = ""
        for i: UInt8 in 0...255 {
            bytes += String(format: "%c", i)
        }
        try stringTest(bytes)
    }

    func testWithAnswer1BZip2Compress() throws {
        try answerTest("test1")
    }

    func testWithAnswer2BZip2Compress() throws {
        try answerTest("test2")
    }

    func testWithAnswer3BZip2Compress() throws {
        try answerTest("test3")
    }

    func testWithAnswer4BZip2Compress() throws {
        try answerTest("test4")
    }

    func testWithAnswer5BZip2Compress() throws {
        try answerTest("test5")
    }

    func testWithAnswer6BZip2Compress() throws {
        try answerTest("test6")
    }

//    func testWithAnswer7BZip2Compress() throws {
//        try answerTest("test7")
//    }

    func testWithAnswer8BZip2Compress() throws {
        try answerTest("test8")
    }

    func testWithAnswer9BZip2Compress() throws {
        try answerTest("test9")
    }

    func testBurrowsWheelerRoundtrip() throws {
        // This test is inspired by the reported issue #38 that uncovered a mistake with a pointer variable in BWT.
        // "1"s can be anything (except zero), but it must be the same byte value in all places.
        // Two consecutive zeros in the middle seem to be crucial for some reason.
        let testData = Data([0, 1, 0, 1, 0, 0, 1, 0, 1])
        let compressedData = BZip2.compress(data: testData)
        let redecompressedData = try BZip2.decompress(data: compressedData)
        XCTAssertEqual(redecompressedData, testData)
    }

}
