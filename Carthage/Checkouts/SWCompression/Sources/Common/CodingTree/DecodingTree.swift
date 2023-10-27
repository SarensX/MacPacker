// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import BitByteData

final class DecodingTree {

    private let bitReader: BitReader

    private let tree: [Int]
    private let leafCount: Int

    init(codes: [Code], maxBits: Int, _ bitReader: BitReader) {
        self.bitReader = bitReader

        // Calculate maximum amount of leaves in a tree.
        self.leafCount = 1 << (maxBits + 1)
        var tree = Array(repeating: -1, count: leafCount)

        for code in codes {
            // Put code in its place in the tree.
            var treeCode = code.code
            var index = 0
            for _ in 0..<code.bits {
                let bit = treeCode & 1
                index = bit == 0 ? 2 * index + 1 : 2 * index + 2
                treeCode >>= 1
            }
            tree[index] = code.symbol
        }
        self.tree = tree
    }

    func findNextSymbol() -> Int {
        var bitsLeft = bitReader.bitsLeft
        var index = 0
        while bitsLeft > 0 {
            let bit = bitReader.bit()
            index = bit == 0 ? 2 * index + 1 : 2 * index + 2
            bitsLeft -= 1
            guard index < self.leafCount
                else { return -1 }
            if self.tree[index] > -1 {
                return self.tree[index]
            }
        }
        return -1
    }

}
