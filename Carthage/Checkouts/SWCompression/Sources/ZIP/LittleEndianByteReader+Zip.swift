// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import BitByteData

extension LittleEndianByteReader {

    func zipString(_ length: Int, _ useUtf8: Bool) -> String? {
        guard length > 0
            else { return "" }
        let stringData = self.data[self.offset..<self.offset + length]
        self.offset += length
        if useUtf8 {
            return String(data: stringData, encoding: .utf8)
        }
        if String.cp437Available && !stringData.needsUtf8() {
            return String(data: stringData, encoding: String.cp437Encoding)
        } else {
            return String(data: stringData, encoding: .utf8)
        }
    }

}

fileprivate extension String {

    // "Latin-US (DOS)" CP437-2147483120
    // Note that this encoding is interpreted differently "depending on the context". This concerns codes in 0-31 range
    // and code 127: sometimes they are treated as normal characters (as was defined by IBM) and sometimes as control
    // characters, matching corresponding ranges of ASCII/UTF-8. The second interpretation, however, doesn't make CP437
    // compatible with UTF-8, as CP437 contains codes in the 80-FF range which are not valid UTF-8 codes.
    // In any case, we are constrained to the implementation provided by Foundation, which currently treats them as
    // control characters.
    static let cp437Encoding = String.Encoding(rawValue: 0x80000400)
    static let cp437Available = String.availableStringEncodings.contains(cp437Encoding)

}

fileprivate extension Data {

    func needsUtf8() -> Bool {
        // UTF-8 can have BOM.
        if self.count >= 3 {
            if self[self.startIndex] == 0xEF && self[self.startIndex + 1] == 0xBB && self[self.startIndex + 2] == 0xBF {
                return true
            }
        }

        var index = self.startIndex
        while index < self.endIndex {
            let byte = self[index]
            if byte <= 0x7F { // This simple byte can exist both in CP437 and UTF-8.
                index += 1
                continue
            }

            // Otherwise, it has to be correct code sequence in case of UTF-8.
            // If code sequence is incorrect, then it is CP437.
            let codeLength: Int
            if byte >= 0xC2 && byte <= 0xDF {
                codeLength = 2
            } else if byte >= 0xE0 && byte <= 0xEF {
                codeLength = 3
            } else if byte >= 0xF0 && byte <= 0xF4 {
                codeLength = 4
            } else {
                return false
            }

            if index + codeLength - 1 >= self.endIndex {
                return false
            }

            for i in 1..<codeLength {
                if self[index + i] & 0xC0 != 0x80 {
                    return false
                }
            }

            if codeLength == 3 {
                let ch = (UInt32(truncatingIfNeeded: self[index]) & 0x0F) << 12 +
                    (UInt32(truncatingIfNeeded: self[index + 1]) & 0x3F) << 6 +
                    UInt32(truncatingIfNeeded: self[index + 2]) & 0x3F
                if ch < 0x0800 || ch >> 11 == 0x1B {
                    return false
                }
            } else if codeLength == 4 {
                let ch = (UInt32(truncatingIfNeeded: self[index]) & 0x07) << 18 +
                    (UInt32(truncatingIfNeeded: self[index + 1]) & 0x3F) << 12 +
                    (UInt32(truncatingIfNeeded: self[index + 2]) & 0x3F) << 6 +
                    UInt32(truncatingIfNeeded: self[index + 3]) & 0x3F
                if ch < 0x10000 || ch > 0x10FFFF {
                    return false
                }
            }
            return true
        }
        // All bytes were in range 0...0x7F, which can be both in CP437 and UTF-8.
        // We solve this ambiguity in favor of CP437.
        return false
    }

}
