# 2.0 Plans

_Last updated: 28.01.2021._

In this document I am going to outline changes that I am planning to implement in the next major update of BitByteData,
version 2.0. I am writing this document with two goals in mind. First, to provide an opportunity to give feedback on
the proposed changes. Secondly, for historical reasons: if at some point in the future I am wondering what were the
reasons for doing any particular change, I will be able to open this document and remind myself of them. Finally, I
would like to mention that all these changes are more or less breaking (according to SemVer, which I am trying to follow
in this project) and this is why I considering them only for the major update.

__Note:__ For breviety, in this text the phrase "`LsbBitReader` and `MsbBitReader`" is combined into `L/MsbBitReader`.

## Improve class and protocol structure of BitByteData

### Motivation

The key idea that was always supposed to be emphasized in the class-protocol structure of BitByteData is that all the
bit readers are also byte readers. Currently, this idea is expressed via `L/MsbBitReader` subclassing `ByteReader`. The
disadvantage of this approach is that the `BitReader` protocol, which both `L/MsbBitReader` conform to, cannot inherit
from `ByteReader` class. This is simply impossible within Swift for a protocol to inherit from a class. The problem with
that arises when you have a variable of the protocol type `BitReader` instead of the concrete class `L/MsbBitReader`.
In this situation you cannot use any byte-reading methods, despite `L/MsbBitReader` being subclasses of `ByteReader`. To
solve this problem, I had to add all byte-reading methods to `BitReader` protocol.

The second motivating problem is the evident hole in the API of BitByteData: absence of any means to read bytes in the
Big Endian order. The proposed restructuring is a good opportunity to introduce a new class for this purpose, which may
be useful in some (though, admittedly, niche) situations.

### Proposed solution

1. Add a new _protocol_ `ByteReader` (sic!) with the following API:

```swift
public protocol ByteReader: AnyObject {

    var size: Int { get }

    var data: Data { get }

    var offset: Int { get set }

    init(data: Data)

    func byte() -> UInt8

    func bytes(count: Int) -> [UInt8]

    func int(fromBytes count: Int) -> Int

    func uint64(fromBytes count: Int) -> UInt64

    func uint32(fromBytes count: Int) -> UInt32

    func uint16(fromBytes count: Int) -> UInt16

}

extension ByteReader {

    public var bytesLeft: Int {
        // ...
    }

    public var bytesRead: Int {
        // ...
    }

    public var isFinished: Bool {
        // ...
    }

}
```

__Note:__ This protocol differs from the byte reading APIs of the `BitReader` protocol's current version. These
changes are discussed in the separate sections of this document.

2. Rename the `ByteReader` class to `LittleEndianByteReader`.

3. Add the conformance to the new `ByteReader` protocol to the renamed `LittleEndianByteReader` class.

4. Add a new class, `BigEndianByteReader`, which also conforms to the `ByteReader` protocol.

5. Make the `BitReader` protocol extend the `ByteReader` protocol.

6. Make both `L/MsbBitReader` no longer subclass the `ByteReader` class (which will be renamed to `LittleEndianByteReader`).

7. Change implementation of both `L/MsbBitReader` to explicitly read bytes in the Little Endian order (currently, they use
   superclass's implementation).

8. Mark all classes (`Little/BigEndianByteReader` and `L/MsbBitReader`) as `final`.

These changes should solve the issues from "Motivation" section.

### Alternatives considered

#### Add a `Self` constraint requirement to the `BitReader` protocol

```swift
public protocol BitReader where Self: ByteReader {
    // ...
}
```

Ideally, this should express the idea that only something that is `ByteReader` (e.g. something that subclasses it) can
conform to the `BitReader` protocol. Additionally, it naturally allows to remove any `ByteReader`'s methods and
properties from the `BitReader` protocol. Unfortunately, the problem _was_ that this language feature hadn't been implemented
until Swift 5 (see [[1]](https://github.com/apple/swift/pull/17851), [[2]](https://bugs.swift.org/browse/SR-5581)).
Since BitByteData 2.0 isn't going to support pre-Swift 5.0 we could go this way instead, but it feels like protocol-based
solution described above is more idiomatic in Swift.

#### Use `ByteReaderProtocol` as a name for the new protocol

The proposed soultions is, probably, the most obvious one. The only hard part in it is, as always, naming:
what would be the name of a protocol if we already have a class with `ByteReader` name? Using Swift Standard Library and
its `IteratorProtocol`, we could name our protocol in a similar manner: `ByteReaderProtocol`. While I haven't tested it,
I have a feeling that this name would incur more source code changes on BitByteData's users. The reason for this feeling
is that I expect that the most common usage scenario is to initialize a byte (bit) reader once and then pass it as an
argument to other functions:

```swift
func f(_ reader: ByteReader) {
    // ...
}

let reader = LsbBitReader(data: data)
f(reader)
```

Since `L/MsbBitReader` are no longer subclasses of `ByteReader` the users would be required to change function declaration
to:

```swift
func (f_ reader: ByteReaderProtocol) {
    //...
}
```

And if there are a lot of functions with `ByteReader` arguments this could quickly get out of control. Additionally, if
we were to introduce a new byte reader for Big Endian byte order (as proposed), we would likely still need to change the
name of `ByteReader` class for a symmetry with the new Big Endian byte reader, which makes this alternative even worse.

#### Use `Le/BeByteReader` as names for the new and renamed classes

I don't think that these names are much better than the full spelling of Little and Big Endian. In practice, as was
stated above, I don't expect the class names of byte readers to be used extensively, thus, I don't think that the
tradeoff ratio between clarity and brevity is good in this case. On the contrast, the abbreviations were used for
`L/MsbBitReader` because their full names are ridiculously long: `LeastSignificantBit` and `MostSignificantBit`
respectively.

#### Add Big-Endian alternatives for `L/MsbBitReader`

As stated above, both `L/MsbBitReader` are going to explicitly support only Little Endian byte order. In theory, we could
add classes with tentative names like `LsbBigEndianBitReader` (`LsbBeBitReader`?), etc. to support Big Endian byte order,
but this would be extremely narrow feature for the price of the increased project size (2 more classes). Finally, it
could be proposed to add a new enum for byte order, add a byte order argument to initializers, and then switch at runtime
on byte order. Unfortunately, this would be detrimental to the overall performance, and thus, this is not considered.

#### Don't mark classes as `final`

This would allow to create new subclasses of byte and bit readers, but honestly, I can't imagine any use case for this.
On the other hand marking classes as `final` enables some compiler optimizations.

## Add (more) means of conversion between readers

Currently, we have converting initializers from the `ByteReader` to `L/MsbBitReader`. In 2.0 update I would like to add
a couple of more: from `L/MsbBitReader` to byte reader(s). While I can't imagine any use cases for these conversions, with
the plan for restructuring BitByteData proposed above these initializers would be extremely easy to implement and,
potentially, even possible to implement as extension methods to corresponding protocols.

## Add missing methods to protocols

In 1.x updates several new methods were introduced both to readers and writers. For the reasons of backwards
compatibility and SemVer, these new methods haven't been added to any of the protocols. The major 2.0 update is the
perfect opportunity to introduce them as new protocol requirements. It is also possible that some of the new and old
protocols' methods could be even provided with default implementation, but I haven't yet assessed that.

List of currently planned additions to the protocols:

1. `BitReader.advance(by:)`
2. `BitWriter.write(unsignedNumber:bitsCount:)`
3. Anything else that is added in 2.0 update

## Remove no-argument versions of `uintX(fromBytes:)` methods

Currently, there are two versions of methods for reading bytes into an unsigned integer: with an argument, which allows
to specify a number of bytes to read, and without the argument, which reads the maximum possible amount of bytes possible
to store in an unsigned integer. These are two of them, because it is possible to implement the "no-argument" version in
a more efficient way. This situation is a bit confusing, and I would like to improve it in the 2.0 update.

There are two potential ways of improvement:

1. Remove the no-argument versions and add natural default argument values to the remaining ones:

```swift
func uint16(fromBytes count: Int = 2) -> UInt16
```

The problem here is that we still need the performance of no-argument functions to be accessible.

2. We could remove the versions with the argument instead and let users deal with splitting big integers into the smaller
ones themselves. There will be some awkwardness, though, with reading big uints at the tail of the data: a user will
probably have to read them as signed integers and then manually convert into the required uint type. But maybe this is a
good thing, since `Int` is supposed to be the most widely used integer type in Swift.

After additional investigation it's become clear that both versions are useful and should be left in as there is no real
benefit to be gained from the removal of one of them. In the `ByteReader` protocol only the versions with arguments
will be included, since they are more general and the existence of no-argument versions is only due to the implementation
reasons. If it becomes possible to make with-argument versions as efficient, the no-argument versions can instead be made
to call the with-argument ones, and in the future they can be more or less easily removed.

## Check if a bit reader is aligned in the willSet observer of the `offset` property

The current philosophy for byte reading in bit readers is that it is only possible to read _bytes_ (and, probably, the
only case when it makes sense) when a bit reader is "aligned" to the byte boundary. This is a carefully maintained
invariant in all _methods_ of both `L/MsbBitReader`, but not in the `offset`'s setter. In other words, it is currently
possible to change `L/MsbBitReader.offset` property when said bit reader is not aligned. This can lead to surprising and
unpredictable behavior, and I am going to prevent this by adding a precondition to the willSet observer of the `offset`
property.

Additionally, it seems like having two property observers (both willSet and didSet) instead of only one (didSet in our
case) actually _improves_ performance. The reason for this is still unknown to me, but it's a very good argument in
support of adding the willSet observer.

## Add methods for reading and writing bits of a negative number

The addition of `L/MsbBitWriter.write(unsignedNumber:bitsCount:)` methods made me realize that there is currently no way
to correctly read and write negative signed integers from and to bits and bytes. Moreover, the current behavior of
`L/MsbBitWriter.write(number:bitsCount:)` and `L/MsbBitReader.int(fromBits:)` functions is unpredictable and unreliable.
It also depends on the platform-specific bit width of the `Int` type and on the values of the arguments in a very subtle
way. To resolve these problems, I would like to do several changes.

1. Add a new enum, `SignedNumberRepresenation`, which will allow to choose an encoding for a signed integer (see the
[wikipedia article](https://en.wikipedia.org/wiki/Signed_number_representations)). Proposed cases of the new enum:

```swift
public enum SignedNumberRepresentation {
    case signMagnitude
    case oneComplementNegatives
    case twoComplementNegatives
    case biased(bias: Int)
    case radixNegativeTwo
}
```

Alternatively, one can name 1's and 2's complement cases as just `oneComplement` and `twoComplement` correspondingly.
We believe that the current naming is better, since it emphasizes the fact that only negative numbers are encoded as the
complements, and positive numbers are encoded as is.

2. Add instance methods to this new enum which will allow to query the minimum and maximum numbers that can be represented
by a given representation using the specified amount of bits:

```swift
public enum SignedNumberRepresentation {
    // ...

    public func minRepresentableNumber(bitsCount: Int) -> Int { ... }

    public func maxRepresentableNumber(bitsCount: Int) -> Int { ... }
}
```

3. Add methods to bit readers and writers which will allow to read signed integers using the specified representation:

``` swift
// BitWriter:
func write(signedNumber: Int, bitsCount: Int, representation: SignedNumberRepresentation = .twoComplementNegatives)

// BitReader:
func signedInt(fromBits count: Int, representation: SignedNumberRepresentation = .twoComplementNegatives) -> Int
```

The default value of the `representation` argument is `.twoComplementNegatives` since it the most common way to encode
signed integers (it is even used internally by Swift).

4. Modify the behavior of the existing functions as following:

```swift
// BitWriter:
func write(number: Int, bitsCount: Int) {
    self.write(unsignedNumber: UInt(bitPattern: number), bitsCount: bitsCount)
}

// BitReader:
func int(fromBits count: Int) -> Int {
    if MemoryLayout<Int>.size == 8 {
        return Int(truncatingIfNeeded: self.uint64(fromBits: count))
    } else if MemoryLayout<Int>.size == 4 {
        return Int(truncatingIfNeeded: self.uint32(fromBits: count))
    } else {
        fatalError("Unknown Int bit width")
    }
}
```

This will allow to partially retain the current behavior of these functions, since it turns out to be useful in some cases.
These implementations will handle positive integers in the same way as before, and will provide consistent behavior for
negative integers. That said, the usage of these functions will be discouraged (via documentation), since they perform
transformations which essentially lose data (the sign of a negative integer).

Technically speaking, byte readers have the same potential problem with reading negative integers. That said, to read
negative integers correctly it is necessary to have an insight into the bits, which compose the bytes, and it cannot be
provided by byte readers by definition. The best thing that can be done is to streamline the implementation of
`int(fromBytes:)` similar to the new implementation of `int(fromBits:)` and update the documentation accordingly to
prevent any misunderstanding. We should refer in the documentation to the `signedInt` functions as a proper way to read
negative integers.

## Other crazy ideas

This is the list of ideas that came to my mind, but they are either too breaking or I haven't assessed them at all. For
these reasons they are very unlikely to be implemented in 2.0 update (or at all, FWIW), but I still decided to briefly
mention them for completeness.

### Make `offset` property zero-based

Currently, `offset` property of all the readers mirrors the `Data`'s behavior: it is not necessarily zero-based. This
"feature" is somewhat inconvenient from the implementation point of view. We could change it to be zero-based, but this
would be extremely breaking change, and in a very subtle way. On the other hand, current behavior is consistent with the
behavior of `Data` which maybe is a good thing.

### Remove `ByteReader.offset` property

Indices in general in Swift world aren't necessarily zero-based. This leads to a problem where the value of the reader's
offset is somewhat useless without knowing what the starting value is.

### Combine `bitMask` and `offset` properties of _bit_ readers

It is possible to add another property which represents continuous _bit_ offset, and compute _byte_ `offset` property
from it (via `/ 8`). With this change it is possible to eliminate internal `bitMask` property and we won't have to check
and update _byte_ offset on every bit read. Unfortunately, there is a problem: the maximum _byte_ offset in this case
would be `Int.max / 8` and this is less than currently possible (`Int.max`).

### More ideas for BitByteData's architecture

#### Inclusion instead of inheritance

One other approach for the design of BitByteData is to use inclusion instead of inheritance to connect bit and byte
readers. I haven't assessed this idea at all, and with the changes proposed above it is very unlikely that this idea
is ever implemented, but it would be still an interesting thought experiment.

#### `ByteReader` as `Data` subclass

One could try to make `ByteReader` a subclass of `Data`. The only problem here, is that `Data` is a struct and it is
impossible to subclass structs in Swift. As an alternative one could also try to sublcass `NSData` instead, but there is
another set of completely unexplored questions (what about `NSMutableData`? what is the future for `NSData`?
what about its Objective-C legacy? what about relationship between Linux and `NSData`?)

### Make `ByteReader` conform to `Sequence`/`IteratorProtocol`

It seems like byte and bit readers do have certain features of a `Sequence` (or maybe some other stdlib's protocol).
In theory it may be useful to conform the readers to these protocols, or even make BitByteData's protocols to extend
these protocols. This idea is actually one of the least crazy ones and likely to be considered at one point in the
(distant?) future.

### Chage `offset` property's type to `UInt64`

In theory there is a problem that some extremely big data instances can lead to undesirable behavior, since `offset` is
of type `Int` and `Int.max < UInt64.max`. Luckily, such big datas are very rare in practice (I haven't seen any). The
other problem is that `Data.Index == Int`. Overall, this is problem to tackle in very-very distant future.
