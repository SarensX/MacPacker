// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

#if os(Linux)
    import CoreFoundation
#endif

import Foundation
import SWCompression
import SwiftCLI

enum Benchmarks: String, CaseIterable, ConvertibleFromString {
    case unGzip = "un-gzip"
    case unBz2 = "un-bz2"
    case unLz4 = "un-lz4"
    case unXz = "un-xz"
    case compDeflate = "comp-deflate"
    case compRatioDeflate = "comp-ratio-deflate"
    case compBz2 = "comp-bz2"
    case compRatioBz2 = "comp-ratio-bz2"
    case compLz4 = "comp-lz4"
    case compRatioLz4 = "comp-ratio-lz4"
    case compLz4Bd = "comp-lz4-bd"
    case compRatioLz4Bd = "comp-ratio-lz4-bd"
    case info7z = "info-7z"
    case infoTar = "info-tar"
    case infoZip = "info-zip"
    case createTar = "create-tar"
    case readerTar = "reader-tar"
    case writerTar = "writer-tar"

    var titleName: String {
        switch self {
        case .unGzip:
            return "GZip Unarchive"
        case .unBz2:
            return "BZip2 Decompress"
        case .unLz4:
            return "LZ4 Decompress"
        case .unXz:
            return "XZ Unarchive"
        case .compDeflate:
            return "Deflate Compress"
        case .compRatioDeflate:
            return "Deflate Compression Ratio"
        case .compBz2:
            return "BZip2 Compress"
        case .compRatioBz2:
            return "BZip2 Compression Ratio"
        case .compLz4:
            return "LZ4 Compress"
        case .compRatioLz4:
            return "LZ4 Compression Ratio"
        case .compLz4Bd:
            return "LZ4 Compress (dependent blocks)"
        case .compRatioLz4Bd:
            return "LZ4 Compression Ratio (dependent blocks)"
        case .info7z:
            return "7-Zip Info"
        case .infoTar:
            return "TAR Info"
        case .infoZip:
            return "ZIP Info"
        case .createTar:
            return "TAR Create"
        case .readerTar:
            return "TAR Reader"
        case .writerTar:
            return "TAR Writer"
        }
    }

    func initialized(_ input: String) -> Benchmark {
        switch self {
        case .unGzip:
            return UnGzip(input)
        case .unBz2:
            return UnBz2(input)
        case .unLz4:
            return UnLz4(input)
        case .unXz:
            return UnXz(input)
        case .compDeflate:
            return CompDeflate(input)
        case .compRatioDeflate:
            return CompRatioDeflate(input)
        case .compBz2:
            return CompBz2(input)
        case .compRatioBz2:
            return CompRatioBz2(input)
        case .compLz4:
            return CompLz4(input)
        case .compRatioLz4:
            return CompRatioLz4(input)
        case .compLz4Bd:
            return CompLz4Bd(input)
        case .compRatioLz4Bd:
            return CompRatioLz4Bd(input)
        case .info7z:
            return Info7z(input)
        case .infoTar:
            return InfoTar(input)
        case .infoZip:
            return InfoZip(input)
        case .createTar:
            return CreateTar(input)
        case .readerTar:
            return ReaderTar(input)
        case .writerTar:
            return WriterTar(input)
        }
    }

    static var allBenchmarks: String {
        return Self.allCases.map { $0.rawValue }.joined(separator: ", ")
    }
}

struct UnGzip: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try GzipArchive.unarchive(archive: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct UnBz2: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try BZip2.decompress(data: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct UnLz4: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try LZ4.decompress(data: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct UnXz: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try XZArchive.unarchive(archive: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct CompDeflate: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        let startTime = DispatchTime.now().uptimeNanoseconds
        _ = Deflate.compress(data: self.data)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
        return self.size / timeElapsed
    }

}

struct CompRatioDeflate: Benchmark {

    let defaultIterationCount: Int = 1
    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func warmupIteration() { }

    func measure() -> Double {
        let outputData = Deflate.compress(data: self.data)
        guard outputData.count > 0
            else { swcompExit(.benchmarkCannotMeasureBadOutSize(Self.self)) }
        return Double(self.size) / Double(outputData.count)
    }

    func format(_ value: Double) -> String {
        return String(format: "%.3f", value)
    }

}

struct CompBz2: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        let startTime = DispatchTime.now().uptimeNanoseconds
        _ = BZip2.compress(data: self.data)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
        return self.size / timeElapsed
    }

}

struct CompRatioBz2: Benchmark {

    let defaultIterationCount: Int = 1
    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func warmupIteration() { }

    func measure() -> Double {
        let outputData = BZip2.compress(data: self.data)
        guard outputData.count > 0
            else { swcompExit(.benchmarkCannotMeasureBadOutSize(Self.self)) }
        return Double(self.size) / Double(outputData.count)
    }

    func format(_ value: Double) -> String {
        return String(format: "%.3f", value)
    }

}

struct CompLz4: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        let startTime = DispatchTime.now().uptimeNanoseconds
        _ = LZ4.compress(data: self.data)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
        return self.size / timeElapsed
    }

}

struct CompRatioLz4: Benchmark {

    let defaultIterationCount: Int = 1
    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func warmupIteration() { }

    func measure() -> Double {
        let outputData = LZ4.compress(data: self.data)
        guard outputData.count > 0
            else { swcompExit(.benchmarkCannotMeasureBadOutSize(Self.self)) }
        return Double(self.size) / Double(outputData.count)
    }

    func format(_ value: Double) -> String {
        return String(format: "%.3f", value)
    }

}

struct CompLz4Bd: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        let startTime = DispatchTime.now().uptimeNanoseconds
        _ = LZ4.compress(data: self.data, independentBlocks: false, blockChecksums: false, contentChecksum: true,
            contentSize: false, blockSize: 4 * 1024 * 1024, dictionary: nil, dictionaryID: nil)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
        return self.size / timeElapsed
    }

}

struct CompRatioLz4Bd: Benchmark {

    let defaultIterationCount: Int = 1
    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func warmupIteration() { }

    func measure() -> Double {
        let outputData = LZ4.compress(data: self.data, independentBlocks: false, blockChecksums: false,
            contentChecksum: true, contentSize: false, blockSize: 4 * 1024 * 1024, dictionary: nil, dictionaryID: nil)
        guard outputData.count > 0
            else { swcompExit(.benchmarkCannotMeasureBadOutSize(Self.self)) }
        return Double(self.size) / Double(outputData.count)
    }

    func format(_ value: Double) -> String {
        return String(format: "%.3f", value)
    }

}

struct Info7z: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try SevenZipContainer.info(container: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct InfoTar: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try TarContainer.info(container: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct InfoZip: Benchmark {

    private let data: Data
    private let size: Double

    init(_ input: String) {
        do {
            let inputURL = URL(fileURLWithPath: input)
            self.data = try Data(contentsOf: inputURL, options: .mappedIfSafe)
            self.size = Double(self.data.count)
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let startTime = DispatchTime.now().uptimeNanoseconds
            _ = try ZipContainer.info(container: self.data)
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct CreateTar: Benchmark {

    private let entries: [TarEntry]
    private let size: Double

    init(_ input: String) {
        do {
            self.entries = try TarEntry.createEntries(input, false)
            self.size = try Double(URL(fileURLWithPath: input).directorySize())
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        let startTime = DispatchTime.now().uptimeNanoseconds
        _ = TarContainer.create(from: self.entries)
        let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
        return self.size / timeElapsed
    }

}

struct ReaderTar: Benchmark {

    private let url: URL
    private let size: Double

    init(_ input: String) {
        do {
            self.url = URL(fileURLWithPath: input)
            let resourceValues = try self.url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                self.size = Double(fileSize)
            } else {
                swcompExit(.benchmarkReaderTarNoInputSize(input))
            }
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let handle = try FileHandle(forReadingFrom: self.url)
            let startTime = DispatchTime.now().uptimeNanoseconds
            var reader = TarReader(fileHandle: handle)
            var isFinished = false
            var infos = [TarEntryInfo]()
            while !isFinished {
                isFinished = try reader.process { (entry: TarEntry?) -> Bool in
                    guard entry != nil
                        else { return true }
                    infos.append(entry!.info)
                    return false
                }
            }
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            try handle.closeCompat()
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

struct WriterTar: Benchmark {

    private let entries: [TarEntry]
    private let size: Double

    init(_ input: String) {
        do {
            self.entries = try TarEntry.createEntries(input, false)
            self.size = try Double(URL(fileURLWithPath: input).directorySize())
        } catch let error {
            swcompExit(.benchmarkCannotSetup(Self.self, input, error))
        }
    }

    func measure() -> Double {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString, isDirectory: false)
            try "".write(to: url, atomically: true, encoding: .utf8)
            let handle = try FileHandle(forWritingTo: url)
            let startTime = DispatchTime.now().uptimeNanoseconds
            var writer = TarWriter(fileHandle: handle)
            for entry in self.entries {
                try writer.append(entry)
            }
            try writer.finalize()
            let timeElapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000_000
            try handle.closeCompat()
            try FileManager.default.removeItem(at: url)
            return self.size / timeElapsed
        } catch let error {
            swcompExit(.benchmarkCannotMeasure(Self.self, error))
        }
    }

}

fileprivate extension URL {

    func directorySize() throws -> Int {
        let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as! [URL]
        return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
        }
    }

}
