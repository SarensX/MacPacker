// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import BitByteData
import SWCompression

struct TestZipExtraField: ZipExtraField {

    static let id: UInt16 = 0x0646

    let size: Int
    let location: ZipExtraFieldLocation

    var helloString: String?

    init(_ byteReader: LittleEndianByteReader, _ size: Int, location: ZipExtraFieldLocation) {
        self.size = size
        self.location = location
        self.helloString = String(data: Data(byteReader.bytes(count: size)), encoding: .utf8)
    }

}
