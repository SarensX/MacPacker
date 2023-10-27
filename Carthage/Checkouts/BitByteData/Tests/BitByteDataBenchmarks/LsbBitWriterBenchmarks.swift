// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitWriterBenchmarks: XCTestCase {

    func testWriteBit() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<4_000_000 {
                writer.write(bit: 0)
                writer.write(bit: 1)
            }
        }
    }

    func testWriteNumberBitsCount() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(number: 55, bitsCount: 7)
            }
        }
    }

    func testWriteUnsignedNumberBitsCount() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(unsignedNumber: 55, bitsCount: 7)
            }
        }
    }

    func testWriteSignedNumber_SM_pos() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: 3256, bitsCount: 13, representation: .signMagnitude)
            }
        }
    }

    func testWriteSignedNumber_SM_neg() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: -3256, bitsCount: 13, representation: .signMagnitude)
            }
        }
    }

    func testWriteSignedNumber_1C_pos() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: 3256, bitsCount: 13, representation: .oneComplementNegatives)
            }
        }
    }

    func testWriteSignedNumber_1C_neg() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: -3256, bitsCount: 13, representation: .oneComplementNegatives)
            }
        }
    }

    func testWriteSignedNumber_2C_pos() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: 3256, bitsCount: 13, representation: .twoComplementNegatives)
            }
        }
    }

    func testWriteSignedNumber_2C_neg() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: -3256, bitsCount: 13, representation: .twoComplementNegatives)
            }
        }
    }

    func testWriteSignedNumber_E127_pos() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: 123, bitsCount: 13, representation: .biased(bias: 127))
            }
        }
    }

    func testWriteSignedNumber_E127_neg() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: -123, bitsCount: 13, representation: .biased(bias: 127))
            }
        }
    }

    func testWriteSignedNumber_RN2_pos() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: 3256, bitsCount: 13, representation: .radixNegativeTwo)
            }
        }
    }

    func testWriteSignedNumber_RN2_neg() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(signedNumber: -2549, bitsCount: 13, representation: .radixNegativeTwo)
            }
        }
    }

    func testAppendByte() {
        self.measure {
            let writer = LsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.append(byte: 37)
            }
        }
    }

}
