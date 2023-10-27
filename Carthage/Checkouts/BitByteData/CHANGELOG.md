# Changelog

## 2.0.3

- There are now minimum deployment targets specified in Swift Package Manager manifest.

## 2.0.2

- Swift 5.0 and 5.1 is no longer supported.
- Increased minimum deployment versions (when installed via CocoaPods or Carthage) for Darwin platforms: macOS from 10.10
to 10.13, iOS from 9.0 to 11.0, tvOS from 9.0 to 11.0, and watchOS from 2.0 to 4.0.

## 2.0.1

- Added an explicit precondition on `bitsCount` argument in the default implementation of the
`BitWriter.write(signedNumber:bitsCount:representation:)` function.
- Added missing documentation about a precondition in `L/MsbBitWriter.write(unsignedNumber:bitsCount:)`.

## 2.0.0

- Swift 4.2 is no longer supported.
- Minimum iOS deployment version (when installed via CocoaPods or Carthage) is now 9.0.
- Renamed the `ByteReader` class to `LittleEndianByteReader`.
- `LittleEndianByteReader` (ex-`ByteReader`) is now a final class.
  - `LsbBitReader` and `MsbBitReader` are no longer its subclasses.
- Added a new `BigEndianByteReader` class with the same set of APIs as `LittleEndianByteReader`.
- Added a `ByteReader` protocol which inherits `AnyObject`.
  - Most of the methods and properties of the previously existing `ByteReader` _class_ are now requirements of the new
  protocol.
  - `ByteReader` provides default implementations for the initializer, which implements conversion from a `BitReader`,
  and for the `bytesLeft`, `bytesRead`, and `isFinished` properties (all of these are not protocol requirements).
  - `ByteReader` provides a default implementation for the `int(fromBytes:)` method.
  - Both `LittleEndianByteReader` and `BigEndianByteReader` now conform to the `ByteReader` protocol.
- Added a `SignedNumberRepresentation` enum with five cases and two instance methods.
- The `BitReader` protocol now inherits the `ByteReader` protocol.
  - Two new method requirements have been added to the `BitReader` protocol: `signedInt(fromBits:representation:)` and
  `advance(by:)`.
  - `BitReader` now provides a default implementation for `int(fromBits:)`.
- It is no longer possible to set the `offset` property of the `LsbBitReader` and `MsbBitReader` classes if they are not
aligned (a precondition crash occurs instead).
- The `signedInt(fromBits:representation:)` function has been added to the `LsbBitReader` and `MsbBitReader` classes
with the default value of `SignedNumberRepresentation.twoComplementNegatives` for the `representation` argument.
- Two new method requirements have been added to the `BitWriter` protocol: `write(unsignedNumber:bitsCount:)` and
`write(signedNumber:bitsCount:representation:)`.
- `BitWriter` now provides default implementations for `write(signedNumber:bitsCount:representation:)` and
`write(number:bitsCount:)`.
  - The default implementation of the `write(number:bitsCount:)` function now has a precondition crash if the `bitsCount`
  argument exceeds the bit width of the integer type on the current platform.
- The `write(unsignedNumber:bitsCount:)` function of the `LsbBitWriter` and `MsbBitWriter` classes now has a
precondition crash if the `bitsCount` argument exceeds the bit width of the integer type on the current platform.
- Documentation has been updated.
  - Added documentation for new APIs.
  - A couple of missing precondition checks are now properly documented.
  - Existing documentation has been made more concise and slightly more grammatically correct.

## 1.4.4

- Fixed a compilation warning about "deprecated class keyword" appearing when using Swift 5.4.

## 1.4.3

- Fixed incompatibility with Swift Package Manager from Swift 4.2.

## 1.4.2

- Improved compatibility with the latest versions of Swift (5.x) and Xcode.

## 1.4.1

- Reverted performance improvements of 1.4.0 update due to their incompatibility with Swift 5.0.

## 1.4.0

- Significantly improved performance of `ByteReader`, `LsbBitReader` and `MsbBitReader`.

## 1.3.1

- Improved performance of `ByteReader`'s functions and properties when compiled with Swift 4.2 compiler.

## 1.3.0

- Updated to support Swift 4.2.
- Added `advance(by:)` function to both `LsbBitReader` and `MsbBitReader`.
- Added `write(unsignedNumber:bitsCount:)` function to both `LsbBitWriter` and `MsbBitWriter` (PR #1 by @cowgp).

## 1.2.0

- Updated to support Swift 4.1.
- Added `bytesLeft` and `bytesRead` computed properties to `ByteReader`.
- Added `int(fromBytes:)`, `uint16(fromBytes:)`, `uint32(fromBytes:)`, and `uint64(fromBytes:)` functions to all readers.
- Added `byte(fromBits:)`, `uint16(fromBits:)`, `uint32(fromBits:)`, and `uint64(fromBits:)` functions to `LsbBitReader`
  and `MsbBitReader`, as well as `BitReader` protocol.
- `int(fromBits:)` function now has a precondition that its argument doesn't exceed `Int` bit width.
- Reverted "disable symbol stripping" change from 1.1.1 update, since underlying problem in Carthage was fixed.
- Minor updates to documentation.

## 1.1.1

- Added missing documentation for `bitsLeft` and `bitsRead` computed properties.
- Disabled symbol stripping in archives generated by Carthage and published on GitHub Releases.

## 1.1.0

- Added converting from `ByteReader` initializers to `LsbBitReader` and `MsbBitReader`, as well as `BitReader` protocol.
- Added `bitsLeft` and `bitsRead` computed properties to `LsbBitReader` and `MsbBitReader`, as well as `BitReader`
  protocol.

## 1.0.2

- Fixed several problems causing incorrect preconditions failures.

## 1.0.1

- Improved performance of `bit()`, `bits(count:)` and `int(fromBits:)` functions for both `LsbBitReader` and `MsbBitReader`.
- More consistent behaviour (precondition failures) for situtations when there is not enough data left.
- Small updates to documentation.

## 1.0.0

- `ByteReader` class for reading bytes.
- `BitReader` protocol, `LsbBitReader` and `MsbBitReader` classes for reading bits (and bytes).
- `BitWriter` protocol, `LsbBitWriter` and `MsbBitWriter` classes for writing bits (and bytes).
