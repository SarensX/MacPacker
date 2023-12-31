//
//  ArchiveTest.swift
//  MacPackerTests
//
//  Created by Arenswald, Stephan (059) on 10.10.23.
//

import Foundation
import XCTest
@testable import MacPacker

enum TestError: Error {
    case testError(String)
}

final class ArchiveTest: XCTestCase {
    static var tempDirectoryURL: URL = {
        let processInfo = ProcessInfo.processInfo
        var tempZipDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        tempZipDirectory.appendPathComponent("mptemp")
        // We use a unique path to support parallel test runs via
        // "swift test --parallel"
        // When using --parallel, setUp() and tearDown() are called
        // multiple times.
        tempZipDirectory.appendPathComponent(processInfo.globallyUniqueString)
        return tempZipDirectory
    }()
    
    override class func setUp() {
        super.setUp()
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: ArchiveTest.tempDirectoryURL.absoluteString) {
                try fileManager.removeItem(at: ArchiveTest.tempDirectoryURL)
            }
            try fileManager.createDirectory(
                at: ArchiveTest.tempDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            XCTFail("Unexpected error while trying to set up test resources.")
        }
    }
    
    override func setUp() {
        let applicationSupportDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        if let url = applicationSupportDirectory {
            do {
                try FileManager.default.removeItem(at: url.appendingPathComponent("ta", conformingTo: .directory))
            } catch {
                print("Could not clear cache because...")
                print(error)
            }
        }
    }
    
    private func getTestFile(name: String) throws -> URL {
        // load all the test files
        guard let file = Bundle(for: type(of: self)).url(forResource: name, withExtension: nil) else {
            throw TestError.testError("\(name) not found")
        }
        return file
    }
    
    func testWrongFileInTest() {
        XCTAssertThrowsError(try getTestFile(name: "someName.txt"))
    }

    func testCreation() throws {
        let archive = Archive2()
        XCTAssertEqual(archive.type, .zip)
        XCTAssertEqual(archive.description, "> nil\n  type: zip")
        XCTAssertEqual(archive.canEdit, true)
    }
    
    func testAddFileToArchive() throws {
        let archive = Archive2()
        let helloFile = try getTestFile(name: "hello.txt")
        try archive.add(urls: [helloFile])
    }
    
    func testAddFileToNonEditableArchive() throws {
        let archive = Archive2()
        archive.canEdit = false
        let helloFile = try getTestFile(name: "hello.txt")
        let saveUrl = ArchiveTest.tempDirectoryURL.appendingPathComponent("someRandom.zip")
        XCTAssertThrowsError(try archive.add(urls: [helloFile]))
        XCTAssertThrowsError(try archive.save(to: saveUrl))
    }
    
    func testCreateEmptyArchiveAndSave() throws {
        let archive = Archive2()
        let saveUrl = ArchiveTest.tempDirectoryURL.appendingPathComponent("testCreateEmptyArchiveAndSave.zip")
        try archive.save(to: saveUrl)
        
        let exists = try saveUrl.checkResourceIsReachable()
        XCTAssertTrue(exists)
    }
    
    func testCreateAndAddFileToArchiveAndSave() throws {
        let archive = Archive2()
        let helloFile = try getTestFile(name: "hello.txt")
        try archive.add(urls: [helloFile])
        let saveUrl = ArchiveTest.tempDirectoryURL.appendingPathComponent("testCreateAndAddFileToArchiveAndSave.zip")
        try archive.save(to: saveUrl)
        
        let exists = try saveUrl.checkResourceIsReachable()
        XCTAssertTrue(exists)
        
        let archive2 = try Archive2(url: saveUrl)
        let count = archive2.items.count
        XCTAssertEqual(count, 1)
    }
    
    func testAddToExistingArchiveAndSave() throws {
        let saveUrl = ArchiveTest.tempDirectoryURL.appendingPathComponent("testAddToExistingArchiveAndSave.zip")
        let helloFile = try getTestFile(name: "hello.txt")
        let bondFile = try getTestFile(name: "bond.txt")
        
        let archive = Archive2()
        try archive.add(urls: [helloFile])
        try archive.save(to: saveUrl)
        
        let archive2 = try Archive2(url: saveUrl)
        let count2 = archive2.items.count
        XCTAssertEqual(count2, 1)
        
        try archive2.add(urls: [bondFile])
        try archive2.save(to: saveUrl)
        
        let archive3 = try Archive2(url: saveUrl)
        let count3 = archive3.items.count
        XCTAssertEqual(count3, 2)
    }
    
    func testLoadLz4() throws {
        let tf = try getTestFile(name: "archive.tar.lz4")
        
        let archive = try Archive2(url: tf)
        let count = archive.items.count
        XCTAssertEqual(count, 1)
    }
    
    func testLoadLz4AndTar() throws {
        let tf = try getTestFile(name: "archive.tar.lz4")
        
        let archive = try Archive2(url: tf)
        var count = archive.items.count
        XCTAssertEqual(count, 1)
        
        try archive.open(archive.items[0])
        count = archive.items.count
        XCTAssertEqual(count, 3)
    }
    
    func testLoadLz4AndTarAndParent() throws {
        let tf = try getTestFile(name: "archive.tar.lz4")
        
        let archive = try Archive2(url: tf)
        var count = archive.items.count
        XCTAssertEqual(count, 1)
        
        try archive.open(archive.items[0])
        count = archive.items.count
        XCTAssertEqual(count, 3)
        
        try archive.open(archive.items[0])
        count = archive.items.count
        XCTAssertEqual(count, 1)
    }
    
    func testLoadZip() throws {
        let tf = try getTestFile(name: "archive.zip")
        
        let archive = try Archive2(url: tf)
        let count = archive.items.count
        XCTAssertEqual(count, 2)
    }
    
    func testLoadZipVariant() throws {
        let tf = try getTestFile(name: "zipVariant.xlsx")
        
        let archive = try Archive2(url: tf)
        let count = archive.items.count
        XCTAssertEqual(count, 4)
    }
    
    func testLoadZipVariantInvalid() throws {
        let tf = try getTestFile(name: "zipVariantInvalid.png")
        
        XCTAssertThrowsError(try Archive2(url: tf))
    }
    
    func testLoadTar() throws {
        let tf = try getTestFile(name: "archive.tar")
        
        let archive = try Archive2(url: tf)
        let count = archive.items.count
        XCTAssertEqual(count, 2)
    }
    
    func testNested1() throws {
        let tf = try getTestFile(name: "archiveNested1.zip")
        
        let archive = try Archive2(url: tf)
        var count = archive.items.count
        XCTAssertEqual(count, 1)
        
        // open folder "Folder/"
        try archive.open(archive.items[0])
        count = archive.items.count
        XCTAssertEqual(count, 2)
        XCTAssertEqual(archive.tempDirs.count, 0)
        
        // open archive "archive.tar.lz4
        try archive.open(archive.items[1])
        count = archive.items.count
        XCTAssertEqual(count, 2)
        XCTAssertEqual(archive.tempDirs.count, 1)
        
        // open archive "archive.tar"
        try archive.open(archive.items[1])
        count = archive.items.count
        XCTAssertEqual(count, 3)
        XCTAssertEqual(archive.tempDirs.count, 2)
        
        let tempDirs = archive.tempDirs
        for tempDir in tempDirs {
            XCTAssertTrue(tempDir.isDirectory)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
        }
        
        try archive.clean()
        XCTAssertEqual(archive.tempDirs.count, 0)
        
        for tempDir in tempDirs {
            XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.path))
        }
    }
    
    func testCleanSpecificArchives() throws {
        let tf = try getTestFile(name: "archiveNested2.zip")
        
        // open 2 archives
        let archive1 = try Archive2(url: tf)
        let archive2 = try Archive2(url: tf)
        
        // open nested archive "archive.tar.lz4 which will
        // create a temp dir
        try archive1.open(archive1.items[0])
        XCTAssertEqual(archive1.tempDirs.count, 1)
        try archive2.open(archive2.items[0])
        XCTAssertEqual(archive2.tempDirs.count, 1)
        
        // check if the temp dirs are there
        for tempDir in archive1.tempDirs {
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
        }
        for tempDir in archive2.tempDirs {
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
        }
        
        // clean first archive and make sure that only those temp
        // dirs are removed
        try archive1.clean()
        XCTAssertEqual(archive1.tempDirs.count, 0)
        for tempDir in archive2.tempDirs {
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
        }
        
        // clean the second archive
        try archive2.clean()
        XCTAssertEqual(archive2.tempDirs.count, 0)
    }
    
    func testMoveUpDirectory() throws {
        let tf = try getTestFile(name: "archiveNested1.zip")
        
        let archive = try Archive2(url: tf)
        XCTAssertEqual(archive.items.count, 1)
        
        try archive.open(archive.items[0])
        XCTAssertEqual(archive.items.count, 2)
        
//        try archive.open(archive.items[0])
//        XCTAssertEqual(archive.items.count, 10)
//
//        try archive.open(archive.items[0])
//        XCTAssertEqual(archive.items.count, 5)
        
//        try archive.open(archive.items[2])
//        XCTAssertEqual(archive.items.count, 10)
    }

}
