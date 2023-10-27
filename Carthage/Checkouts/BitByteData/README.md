# BitByteData

[![Swift 5.2+](https://img.shields.io/badge/Swift-5.2+-blue.svg)](https://developer.apple.com/swift/)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/tsolomko/BitByteData/master/LICENSE)
[![Build Status](https://dev.azure.com/tsolomko/BitByteData/_apis/build/status/tsolomko.BitByteData?branchName=develop)](https://dev.azure.com/tsolomko/BitByteData/_build/latest?definitionId=2&branchName=develop)

A Swift framework with classes for reading and writing bits and bytes. Supported platforms include Apple platforms,
Linux, __and Windows__.

## Installation

BitByteData can be integrated into your project using either Swift Package Manager, CocoaPods, or Carthage.

### Swift Package Manager

To install using SPM, add BitByteData to you package dependencies and specify it as a dependency for your target, e.g.:

```swift
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/tsolomko/BitByteData.git",
                 from: "2.0.0")
    ],
    targets: [
        .target(
            name: "TargetName",
            dependencies: ["BitByteData"]
        )
    ]
)
```

More details you can find in [Swift Package Manager's Documentation](https://github.com/apple/swift-package-manager/tree/main/Documentation).

### CocoaPods

Add `pod 'BitByteData', '~> 2.0'` and `use_frameworks!` lines to your Podfile.

To complete installation, run `pod install`.

### Carthage

Add to your Cartfile `github "tsolomko/BitByteData" ~> 2.0`.

Then:

1. If you use Xcode 12 or later you should run `carthage update --use-xcframeworks`. After that drag
and drop the `BitByteData.xcframework` file from the `Carthage/Build/` directory into the "Frameworks, Libraries, and
Embedded Content" section of your target's "General" tab in Xcode.

2. If you use Xcode 11 or earlier you should run `carthage update`. After that drag and drop the
`BitByteData.framework` file from from the `Carthage/Build/<platform>/` directory into the "Embedded Binaries" section
of your target's "General" tab in Xcode.

## Migration to 2.0

There is a number of breaking changes in the 2.0 update. In this section you can find a list of modifications you need
to perform to your code to make it compile with BitByteData 2.0. For more information, please refer to either
[2.0 Release Notes](https://github.com/tsolomko/BitByteData/releases/tag/2.0.0) or
[API Reference Documentation](http://tsolomko.github.io/BitByteData).

1. `ByteReader` class has been renamed to `LittleEndianByteReader`.

    __Solution:__ Change all occurrences in your code of `ByteReader` to `LittleEndianByteReader`.

2. `BitReader` protocol has two new method requirements: `signedInt(fromBits:representation:)` and `advance(by:)`.

    __Solution:__ If you have your own type that conforms to the `BitReader` protocol you need to implement these two
    methods.

3. `BitWriter` protocol has two new method requirements: `write(unsignedNumber:bitsCount:)` and
`write(signedNumber:bitsCount:representation:)`.

    __Solution:__ If you have your own type that conforms to the `BitWriter` protocol you need to implement the
`write(unsignedNumber:bitsCount:)` function (the second function has a default implementation).

4. The setter of the `offset` property of the `LsbBitReader` and `MsbBitReader` classes will now crash if the reader
is not aligned.

    __Solution:__ If you set this property directly, make sure that the reader is aligned, for example, by checking the
`isAligned` property.

5. The default implementation of the `BitWriter.write(number:bitsCount:)` function and the
`write(unsignedNumber:bitsCount:)` function of the `LsbBitWriter` and `MsbBitWriter` classes now crash if the
`bitsCount` argument exceeds the bit width of the integer type on the current platform.

    __Solution:__ If you use these functions directly, make sure that the `bitsCount` argument has a valid value.

In addition, BitByteData 2.0 provides new functionality for working with signed integers more correctly. If you were
working with signed integers before, consider using the new `BitReader.signedInt(fromBits:representation:)` and
`BitWriter.write(signedNumber:bitsCount:representation:)` functions instead of `int(fromBits:)` and
`write(number:bitsCount:)`, respectively.

## Usage

To read bytes use either `LittleEndianByteReader` or `BigEndianByteReader` class, which implement the `ByteReader`
protocol.

For reading bits there are also two classes: `LsbBitReader` and `MsbBitReader`, which implement the `BitReader` protocol
for two bit-numbering schemes ("LSB 0" and "MSB 0" correspondingly), though they only support Little Endian byte order.
Since the `BitReader` protocol inherits from `ByteReader`, you can also use the `LsbBitReader` and `MsbBitReader`
classes to read bytes (but they must be aligned when doing so, see documentation for more details).

Writing bits is implemented for two bit-numbering schemes as well: the `LsbBitWriter` and `MsbBitWriter` classes. Both
of them conform to the `BitWriter` protocol.

__Note:__ All readers and writers aren't structs, but classes intentionally to make it easier to pass them as references
to functions. This allows to eliminate potential copying and avoid writing extra `inout`s and ampersands all over the
code.

### Documentation

Every function or type of BitByteData's public API is documented. This documentation can be found at its own
[website](http://tsolomko.github.io/BitByteData) or via a slightly shorter link:
[bitbytedata.tsolomko.me](http://bitbytedata.tsolomko.me)

## Contributing

Whether you find a bug, have a suggestion, idea, feedback or something else, please
[create an issue](https://github.com/tsolomko/BitByteData/issues) on GitHub. If you have any questions, you can ask
them on the [Discussions](https://github.com/tsolomko/BitByteData/discussions) page.

If you'd like to contribute, please [create a pull request](https://github.com/tsolomko/BitByteData/pulls) on GitHub.

__Note:__ If you are considering working on BitByteData, please note that the Xcode project (BitByteData.xcodeproj)
was created manually and you shouldn't use the `swift package generate-xcodeproj` command.

### Performance and benchmarks

One of the most important goals of BitByteData's development is high speed performance. To help achieve this goal there
are benchmarks for every function in the project as well as a handy command-line tool, `benchmarks.py`, which helps to
run, show, and compare benchmarks and their results.

If you are considering contributing to the project please make sure that:

1. Every new function has also a new benchmark added.
2. Other changes to existing functionality do not introduce performance regressions, or, at the very least, these
   regressions are small and such performance tradeoff is necessary and justifiable.

Finally, please note that any meaningful comparison can be made only between benchmarks run on the same hardware and
software.
