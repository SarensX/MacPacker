// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/**
 A type that contains functions for writing `Data` bit-by-bit and byte-by-byte using "MSB 0" bit numbering scheme.
 */
public final class MsbBitWriter: BitWriter {

    /// Data which contains the writer's output (the last byte, that is currently being written, is not included).
    public private(set) var data: Data = Data()

    private var bitMask: UInt8 = 128
    private var currentByte: UInt8 = 0

    /// True, if a bit pointer is aligned to a byte boundary.
    public var isAligned: Bool {
        return self.bitMask == 128
    }

    /// Creates an instance for writing bits and bytes.
    public init() { }

    /**
     Writes a `bit`, advancing by one bit position.

     - Precondition: The `bit` must be either 0 or 1.
     */
    public func write(bit: UInt8) {
        precondition(bit <= 1, "A bit must be either 0 or 1.")

        self.currentByte += self.bitMask * bit

        if self.bitMask == 1 {
            self.bitMask = 128
            self.data.append(self.currentByte)
            self.currentByte = 0
        } else {
            self.bitMask >>= 1
        }
    }

    /**
     Writes an unsigned `number`, advancing by `bitsCount` bit positions.

     This method may be useful for writing numbers, that would cause an integer overflow crash if converted to `Int`.

     - Note: The `number` will be truncated if the `bitsCount` is less than the amount of bits required to fully
     represent the value of `number`.
     - Note: Bits of the `number` are processed using the same bit-numbering scheme as of the writer (i.e. "MSB 0").
     - Precondition: Parameter `bitsCount` must be in the `0...UInt.bitWidth` range.
     */
    public func write(unsignedNumber: UInt, bitsCount: Int) {
        precondition(0...UInt.bitWidth ~= bitsCount)
        var mask = (1 as UInt) << (bitsCount - 1)
        for _ in 0..<bitsCount {
            self.write(bit: unsignedNumber & mask > 0 ? 1 : 0)
            mask >>= 1
        }
    }

    /**
     Writes a `byte`, advancing by one byte position.

     - Precondition: The writer must be aligned.
     */
    public func append(byte: UInt8) {
        precondition(isAligned, "BitWriter is not aligned.")
        self.data.append(byte)
    }

    /**
     Aligns a bit pointer to a byte boundary, i.e. moves the bit pointer to the first bit of the next byte, filling all
     skipped bit positions with zeros. If the writer is already aligned, then does nothing.
     */
    public func align() {
        guard self.bitMask != 128
            else { return }

        self.data.append(self.currentByte)
        self.currentByte = 0
        self.bitMask = 128
    }

}
