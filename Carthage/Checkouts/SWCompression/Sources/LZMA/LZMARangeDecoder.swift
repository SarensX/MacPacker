// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import BitByteData

struct LZMARangeDecoder {

    private let byteReader: LittleEndianByteReader

    private var range = 0xFFFFFFFF as UInt32
    private var code = 0 as UInt32
    private(set) var isCorrupted = false

    var isFinishedOK: Bool {
        return self.code == 0
    }

    init(_ byteReader: LittleEndianByteReader) throws {
        // To initialize range decoder at least 5 bytes are necessary.
        guard byteReader.bytesLeft >= 5
            else { throw LZMAError.rangeDecoderInitError }

        self.byteReader = byteReader

        let byte = self.byteReader.byte()
        self.code = self.byteReader.uint32().byteSwapped
        guard byte == 0 && self.code != self.range
            else { throw LZMAError.rangeDecoderInitError }
    }

    init() {
        self.byteReader = LittleEndianByteReader(data: Data())
    }

    /// `range` property cannot be smaller than `(1 << 24)`. This function keeps it bigger.
    mutating func normalize() {
        if self.range < LZMAConstants.topValue {
            self.range <<= 8
            self.code = (self.code << 8) | UInt32(byteReader.byte())
        }
    }

    /// Decodes sequence of direct bits (binary symbols with fixed and equal probabilities).
    mutating func decode(directBits: Int) -> Int {
        var res: UInt32 = 0
        var count = directBits
        repeat {
            self.range >>= 1
            self.code = self.code &- self.range
            let t = 0 &- (self.code >> 31)
            self.code = self.code &+ (self.range & t)

            if self.code == self.range {
                self.isCorrupted = true
            }

            self.normalize()

            res <<= 1
            res = res &+ (t &+ 1)
            count -= 1
        } while count > 0
        return res.toInt()
    }

    /// Decodes binary symbol (bit) with predicted (estimated) probability.
    mutating func decode(bitWithProb prob: inout Int) -> Int {
        let bound = (self.range >> UInt32(LZMAConstants.numBitModelTotalBits)) * UInt32(prob)
        let symbol: Int
        if self.code < bound {
            prob += ((1 << LZMAConstants.numBitModelTotalBits) - prob) >> LZMAConstants.numMoveBits
            self.range = bound
            symbol = 0
        } else {
            prob -= prob >> LZMAConstants.numMoveBits
            self.code -= bound
            self.range -= bound
            symbol = 1
        }
        self.normalize()
        return symbol
    }

}
