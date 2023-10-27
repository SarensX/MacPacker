# Changelog

## 4.8.5

- Fixed an issue where in some cases LZMA2 decompression would fail with an incorrectly thrown error.

## 4.8.4

- Fixed an issue where in some cases BZip2 compression would produce incorrect output.
- `TarReader` methods now always return `nil` after reaching the end of a TAR container.

## 4.8.3

- There are now minimum deployment targets specified in Swift Package Manager manifest.
- The properties of `GzipHeader` are now `var`-properties (instead of `let`).
- GZip extra fields are now supported.
    - Added `GzipHeader.ExtraField` struct.
    - Added `GzipHeader.extraFields` property.
    - Added a new `extraFields` argument to `GzipArchive.archive` function (with a default array empty value).
- Fixed potential crashes that could occur when processing GZip archives truncated in a header or a "footer".
- Some non-well-formed values of PAX extended header records no longer cause `TarError.wrongPaxHeaderEntry` to be thrown.
    - The record values with newline characters are now fully processed.
    - The record values that do not contain UTF-8 strings are now ignored.
- swcomp changes:
    - The symbolic links are now extracted with the values recorded in the containers.
    - The hard links are now extracted from TAR containers instead of being ignored.
    - Fixed build issues on Linux and Windows.
    - `benchmark` is now a command group with two commands, `run` and `show`.
    - Added `-a`, `--append` option to the `benchmark run` command.
    - Added `-d`, `--description` option to the `benchmark run` command.
    - Added `-t`, `--preserve-timestamp` option to the `benchmark run` command.
    - The file format of saved results is now more flexible and allows multi-way comparisons.
    - Improved precision of time measurements in benchmarks.

## 4.8.2

- Swift 5.1 is no longer supported.
- Increased minimum deployment versions (when installed via CocoaPods or Carthage) for Darwin platforms: macOS from 10.10
to 10.13, iOS from 9.0 to 11.0, tvOS from 9.0 to 11.0, and watchOS from 2.0 to 4.0.
- Fixed issues when building for iOS either directly or via Carthage on systems with Xcode 14.
- Fixed potential crashes that could occur when decompressing truncated Deflate inputs.
- swcomp changes:
    - swcomp is now enabled by default in Swift Package Manager manifest.
    - Added `-l`, `--list` option to container commands (`7z`, `tar`, and `zip`).
    - Systematized error exit codes and messages.
    - Added `-s`, `--save` option to the `benchmark` command.
    - Added `-c`, `--compare` option to the `benchmark` command.
    - Added `-i`, `--iteration-count` option to the `benchmark` command.
    - Added `-W`, `--no-warmup` option to the `benchmark` command.
    - Benchmarks now output standard deviation instead of speed uncertainty.

## 4.8.1

- Fix incorrect detection of truncated GZip archives.

## 4.8.0

- Added `TarReader` and `TarWriter` structs which allow more iterative work with TAR containers while helping with
reducing memory usage.
- Fixed a crash that could happen when decompressing Deflate and BZip2 inputs truncated in a certain way.
- In API reference documentation the Container category has been split into separate categories for each container type.
- swcomp changes:
    - Certain error messages were made a bit clearer.
    - Added `reader-tar` and `writer-tar` subcommands to the `benchmark` command.
    - Changed the printing format of the benchmark speed.

## 4.7.0

- Added full-featured support for LZ4 compression and decompression by introducing 5 new functions inside `LZ4` enum.
    - This enum conforms to the `DecompressionAlgorithm` and `CompressionAlgorithm` protocols.
    - Added SWCompression/LZ4 subspec for CocoaPods users.
    - Added support for LZ4 algorithm used in 7-Zip containers.
- Added `DataError` enum which conforms to `Error` and `Equatable` protocols.
- Swift 5.0 is no longer supported.
- Fixed an issue where in some cases Deflate compression would produce incorrect output.
- Optimized performance of Deflate compression.
- swcomp changes:
    - Increased the lowest required version of SwiftCLI dependency to 6.0.0.
    - Added `lz4` command with many options to support all LZ4 features (both compression and decompression).
    - Added `--use-format` option to the `tar` command which when used with the `-c` option allows to force usage of a
    selected TAR format when creating a TAR container.
    - The `-j` and `-z` options of the `tar` command can now be used together with the `-c` option to create compressed
    TAR containers.
    - Added `un-lz4`, `comp-lz4`, and `comp-lz4-bd` subcommands to the `benchmark` command.
    - Benchmark commands for compression now report compression ratio.

## 4.6.1

- Fixed a crash in LZMA2 when trying to process an empty `Data`.
- swcomp changes:
    - Added `benchmark create-tar` benchmarking command.
    - Benchmarking results are now printed in the units of speed instead of time elapsed.

## 4.6.0

- Swift 4.2 is no longer supported.
- Minimum iOS deployment version (when installed via CocoaPods or Carthage) is now 9.0.
- Increased the lowest required version of BitByteData dependency to 2.0.
- Added the `TarContainer.create(from:force:)` function which allows to specify TAR format.
    - It is now possible to create TAR containers of GNU, ustar (POSIX), and pre-POSIX formats.
- The `TarContainer.create(from:)` function (alongside with the newly added function) no longer throws.
    - The `TarCreateError.utf8NonEncodable` error is now never thrown.
- Handling of truncated TAR containers should now be more consistent.
    - Previously introduced check for truncated containers now throws the `TarError.tooSmallFileIsPassed` error instead
    of `TarError.wrongField`.
- Documentation has been updated:
    - Adjusted documentation of the `TarEntryInfo` properties to account for other formats used in creation of a
    container.
    - Adjusted documentation of the `TarError.tooSmallFileIsPassed` error to mention its use in all situations when
    truncated data is encountered.
- swcomp changes:
    - `zip -i` command now prints entry comments only if they are not empty.
    - Slight grammatical improvements to the help messages of swcomp.

## 4.5.11

- Fixed a crash when processing a truncated TAR file.
- Added missing documentation for `LZMAProperties.init()`.
- Windows is now supported.

## 4.5.10

- Fixed compilation issues on Windows (PR #22 by @trametheka).
- Performed minor optimizations to BZip2 and Deflate compression functionality.
- Increased the lowest required version of BitByteData dependency to 1.4.4.

## 4.5.9

- Improved performance of LZMA/LZMA2 and, consequently, of XZ.
- Fixed a rare crash when processing a BZip2 archive which uses non-standard (but allowed) run length values.

## 4.5.8

- Fixed incompatibility with Carthage `--use-xcframeworks` method of installation.

## 4.5.7

- Fixed a crash when trying to open a very small file as a 7-Zip container, a BZip2 "archive", a GZip archive (both when
  using `unarchive` and `multiUnarchive`), a LZMA "archive", a XZ archive (both when using `unarchive` and `splitUnarchive`),
  a ZIP container, or a Zlib archive.
- Fixed a crash when trying to open an unexpectedly truncated file as a GZip or XZ archive.
- Fixed a crash when trying to open an invalid file as a ZIP container. The `ZipError.notFoundCentralDirectoryEnd` error
  is now thrown instead as was originally intended.
- Fixed a crash when trying to read a GZip or Zlib header from a very small file.
- Fixed a compilation warning in BZip2.

## 4.5.6

- Fixed a compiling issue on Linux with Swift 5.3.

## 4.5.5

- Fixed a crash which was sometimes happening when encountering non well-formed Extended Timestamp in ZIP files.

## 4.5.4

- Fixed issues when installing using SPM or Xcode in certain situations.
- Fixed incompatibility with Swift Package Manager from Swift 4.2.

## 4.5.3

- Improved compatibility with the latest versions of Swift (5.x) and Xcode.

## 4.5.2

- Increased the lowest required version of BitByteData dependency to 1.4.1.

## 4.5.1

- Minimum required version of BitByteData is now 1.4.0.
- Updated to support Swift 4.2.
- Added default values to the properties of `LZMAProperties` struct.
- Added `init()` to `LZMAProperties` struct.
- Improved the detection of Swift versions less than 4.2 in the workaround for the crash in `Data.prefix(upTo:)`.
- Documentation updates:
    - Fixed an outdated example in README (PR #4 by @brianantonelli).
    - Fixed grammar issues related to the usage of articles, during/while, and others.
- swcomp changes:
    - Minimum required version of SwiftCLI is now 5.2.0.
    - Improved the layout of output of benchmark commands.

## 4.5.0

- Added APIs which allow to specify LZMA properties for decompression:
    - Added `LZMAProperties` struct with simple memberwise initializer.
    - Added `LZMA.decompress(data:properties:uncompressedSize:)` function with `uncompressedSize` argument being optional.
- Added support Delta "filter" in both XZ archives and 7-Zip containers.
- Added support for SHA-256 check type in XZ archives.
- Added `ZipEntryInfo.crc` property.
- Fixed incorrect result of `XZArchive.unarchive` and `XZArchive.splitUnarchive` functions when more than one "filter"
  was used.
- Reduced in-memory size of `ZipEntryInfo` instances.
- Clarified documentation for `LZMA.decompress(data:)` to explain expectation about `data` argument.
- swcomp changes:
    - `zip -i` command now also prints CRC32 for all entries.
    - `-v` is now accepted as an alias for `--verbose` option.

## 4.4.0

- Added APIs which allow creation of new TAR containers:
    - Added `TarContainer.create(from:)` function.
    - Added `TarCreateError` error type with a single case `utf8NonEncodable`.
- `TarEntry.info` and `TarEntry.data` are now `var`-properties (instead of `let`).
- Accessing setter of `TarEntry.data` now automatically updates corresponding `TarEntry.info.size` with `data.count`
  value (or 0 if `data` is `nil`).
- Added `TarEntry.init(info:data:)` initializer.
- Most public properties of `TarEntry` are now `var`-properties (instead of `let`). Exceptions: `size` and `type`.
- Added `TarEntryInfo.init(name:type:)` initializer.
- Improved compatibility with other TAR implementations:
    - All string fields of TAR headers are now treated as UTF-8 strings.
    - Non-well-formed integer fields of TAR headers no longer cause `TarError.wrongField` to be thrown and instead
      result in `nil` values of corresponding properties of `TarEntryInfo` (exception: `size` field).
    - Base-256 encoding of numeric fields is now supported.
    - Leading NULLs and whitespaces in numeric fields are now correctly skipped.
    - Sun Extended Headers are now processed as local PAX extended headers instead of being considered entries with
      `.unknown` type.
    - GNU TAR format features for incremental backups are now partially supported (access and creation time).
- `TarContainer.formatOf` now correctly returns `TarFormat.gnu` when GNU format "magic" field is encountered.
- A new (copy) `Data` object is now created for `TarEntry.data` property instead of using a slice of input data.
- Fixed incorrect file name of TAR entries from containers with GNU TAR format-specific features being used.
- Fixed `TarError.wrongPaxHeaderEntry` error being thrown when header with multi-byte UTF-8 characters is encountered.
- Fixed incorrect values of `TarEntryInfo.ownerID`, `groupID`, `deviceMajorNumber` and `deviceMinorNumber` properties.
- Slightly improved performance of LZMA/LZMA2 operations by making internal classes declared as `final`.
- swcomp changes:
    - Added `-c`, `--create` option to `tar` command which creates a new TAR container.
    - Output of bencmark commands is now properly flushed on non-Linux platforms.
    - Results for omitted iterations of benchmark commands are now also printed.
    - Iteration number in benchmark commands is now printed with leading zeros.
    - Fixed compilation error on Linux platforms due to `ObjCBool` no longer being an alias for `Bool`.

## 4.3.0

- Updated to support Swift 4.1.
- Minuimum required version of BitByteData is now 1.2.0.
- Added APIs which allow to use custom ZIP Extra Fields.
    - Added `ZipExtraField` protocol.
    - Added `ZipExtraFieldLocation` enum.
    - Added `ZipContainer.customExtraFields` property.
    - Added `ZipEntryInfo.customExtraFields` property.
- Added APIs which allow to get information about TAR's format:
    - Added `TarContainer.Format` enum which represents various formats of TAR containers.
    - Added `TarContainer.formatOf(container:)` function which returns format of the container.
    - Added `-f`, `--format` option to swcomp's `tar` command which prints format of TAR container.
- Added `TarEntryInfo.compressionMethod` property which is always equal to `.copy`.
- Added documenation for `Container.Entry` and `ContainerEntry.Info` associated types.
- Reverted "disable symbol stripping" change from 4.2.0 update, since underlying problem was fixed in Carthage.
- Benchmarks changes:
    - Iterations number increased from 6 to 10.
    - There is now a zeroth iteration which is excluded from averages.

## 4.2.2

- Fixed skipping entries in `SevenZipContainer.open(container:)` in some rare cases.
- Fixed crash in `SevenZipContainer.info(container:)` when either entry's size or CRC32 is not present in the container.
- Updated some Container-related documentation.

## 4.2.1

- Now accepts 7-Zip containers with minor format versions from 1 to 4 (previously, was only 4).

## 4.2.0

- Minuimum required version of BitByteData is now 1.1.0.
- Added `ownerID` and `groupID` properties to `ZipEntryInfo`, which stores uid and gid from Info-ZIP New Unix and
  Info-Zip Unix extra fields.
- Added `unknownExtendedHeaderRecords` property to `TarEntryInfo` which includes unrecognized entries from PAX
  extended headers.
- Prevent double slashes in `TarEntryInfo.name` when prefix header's field was used, but it had trailing slash,
  which is, by the way, against TAR format.
- Additionally improved speed of BZip2 compression: Now doesn't create more Huffman trees when they cannot be used,
  since maximum amount of Huffman tables was generated.
- Disable symbol stripping in archives generated by Carthage and published on GitHub Releases.
- swcomp changes:
    - Replaced 9 block size options of `bz2` command with a single one: `-b` (`--block-size`).
    - Now prints entry type-specific properties in output of `tar`, `zip` and `7z` commands with
      `-i` (`--info`) option.
    - Renamed `perf-test` command group to `benchmark`.

## 4.1.1

- Fixed incorrect value of `TarEntryInfo.name` when ustar format's "prefix" field was used.
- Updated documentation for `TarEntryInfo`.

## 4.1.0

- Some internal classes were published as a separate project, [BitByteData](https://github.com/tsolomko/BitByteData).
  This project is now used by SWCompression.
- Several performance improvements have been made.
- "Fixed" a problem when some BZip2 archives created by SWCompression could not be opened by original BZip2 implementation.
- Modification time stored in ZIP's "native" field is now calculated relative to current system's calendar and time zone.
- swcomp additions:
    - Added `-1`...`-9` options to `bz2 -c` command which specifies what block size to use for BZip2 compression.
    - Added `-i`, `--info` option to `gz` command which prints GZip's header.
    - Added `comp-deflate` and `comp-bz2` subcommands to `perf-test` command
      which can be used for performance testing of Deflate and BZip2 compression.
    - Corrected descriptions of `-e` options for `zip`, `tar` and `7z` commands.
    - Now sets permissions for extracted files only if they are greater than 0.

## 4.0.1

- Git tag for updates no longer has "v" prefix.
- Fixed incorrectly thrown `XZError.wrongDataSize` without actually trying to decompress anything.
- Fixed crash when opening 7-Zip containers with more than 255 entries with empty streams.
- No longer verify if ZIP string field needs UTF-8 encoding, if language encoding flag is set.
- Reduced memory usage by Deflate compression.
- Added "perf-test" command to swcomp, which is used for measuring performance.
- Internal changes to tests:
    - `LONG_TESTS` and `PERF_TESTS` compiler flags are no longer used for testing.
    - Reduced size of test6 and test7 from 5 megabytes to 1 megabyte.
    - Removed test7 for BZip2 compression.
    - Added results for 4.0.0 and 4.0.1 from new performance measuring scheme.

## 4.0.0

- Reworked Container API:
    - New protocol: `ContainerEntryInfo`.
    - `ContainerEntry`:
        - Now has an associated type `Info: ContainerEntryInfo`.
        - Now has only two members: `info` and `data` properties; all previous members were removed.
    - `Container`:
        - Now has an associated type `Entry: ContainerEntry`.
        - `open` function now returns an array of associated type `Entry`.
        - Added new function `info`, which returns an array of `Entry.Info`.
    - All existing ZIP, TAR and 7-Zip types now conform to these protocols.
        - All `Entry` types now have only two members: `info` and `data` (see `ContainerEntry` protocol).
    - Added missing types for ZIP, TAR and 7-Zip with conformance to these protocols.
    - Standardized behavior when `ContainerEntry.data` can be `nil`:
        - If entry is a directory.
        - If data is unavailable, but error wasn't thrown for some reason.
        - 7-Zip only: if entry is an anti-file.

- Added several new common types, which are used across the framework:
    - `CompressionMethod`.
        - Used in `GzipHeader.compressionMethod`, `ZlibHeader.compressionMethod`, `ZipEntryInfo.compressionMethod`.
    - `ContainerEntryType`.
        - Used in `ContainerEntryInfo.type` and types that conform to `ContainerEntryInfo` protocol.
    - `DosAttributes`.
        - It is the same as previous `SevenZipEntryInfo.DosAttributes` type.
        - Used in `SevenZipEntryInfo.dosAttributes` and `ZipEntryInfo.dosAttributes`.
    - `Permissions`.
        - It is the same as previous `SevenZipEntryInfo.Permissions` type.
        - Used in `ContainerEntryInfo.permissions` and types that conform to `ContainerEntryInfo` protocol.
    - `FileSystemType`.
        - Used in `GzipHeader.osType` and `ZipEntryInfo.fileSystemType`.
- Removed `GzipHeader.FileSystemType`.
- Removed `GzipHeader.CompressionMethod`.
- Removed `TarEntry.EntryType`.

- Removed following errors:
    - `SevenZipError.dataIsUnavailable`
    - `LZMAError.decoderIsNotInitialised`
    - `LZMA2Error.wrongProperties` (`LZMA2Error.wrongDictionarySize` is thrown instead).
    - `TarError.wrongUstarVersion`.
    - `TarError.notAsciiString` (`TarError.wrongField` is thrown instead).
    - `XZError.wrongFieldValue` (`XZError.wrongField` is thrown instead).
- Renamed following errors:
    - `BZip2Error.wrongHuffmanLengthCode` to `BZip2Error.wrongHuffmanCodeLength`.
    - `BZip2Error.wrongCompressionMethod` to `BZip2Error.wrongVersion`.
    - `TarError.fieldIsNotNumber` to `TarError.wrongField`.
    - `XZError.reservedFieldValue` to `XZError.wrongField`.
- Standardized behavior for errors named similar to `wrongCRC`:
    - These errors mean that everything went well, except for comparing the checksum.
    - Their associated values now contain all "successfully" unpacked data, including the one, which caused such an error.
        - This change affects `BZip2.decompress`, `GzipArchive.multiUnarchive`, `XZArchive.unarchive`,
        `XZArchive.splitUnarchive`, `ZipContainer.open`.
    - Some of these errors now have arrays as associated values to account for the situations with unpacked data split.
        - This change affects `GzipArchive.multiUnarchive`, `XZArchive.unarchive`, `XZArchive.splitUnarchive`, `ZipContainer.open`.

- Removed `SevenZipEntryInfo.isDirectory`. Use `type` property instead.
- `SevenZipEntryInfo.name` is no longer `Optional`.
    - Now throws `SevenZipError.internalStructureError` when file names cannot be properly processed.
    - Entries now have empty strings as names when no names were found in container.
- Renamed `XZArchive.multiUnarchive` to `XZArchive.splitUnarchive`.
- `XZArchive.unarchive` now processes all XZ streams similar to `splitUnarchive`, but combines them into one output `Data`.
- Fixed "bitReader is not aligned" precondition crash in Zlib.
- Fixed potential incorrect behavior when opening ZIP containers with size bigger than 4 GB..
- Updated to use Swift 4.
- Various improvements to documentation.
- "swcomp" is now included is as part of this repository.

## 3.4.0

- Added support for BZip2 compression.
- Added `CompressionAlgorithm` protocol.
- `Deflate` now conforms to `CompressionAlgorithm` protocol (as well as `BZip2`).
- `Deflate.compress(data:)` no longer throws.
- `ZlibArchive.archive(data:)` no longer throws.
- Fixed crash in some rare cases for corrupted BZip2 archives (but throws `BZip2Error` instead).

## 3.3.1

- Fixed out of range index crash in BitReader.

## v3.3.0

- Introduced support for 7-Zip containers.
- Added `TarEntry.isLink`.
- Added `ZipEntry.isLink` and `ZipEntry.linkPath`.
- Added `ZipEntry.isTextFile`.
- Added `ContainerEntry.isLink` and `ContainerEntry.linkPath`.
- Added support for NTFS extra fields in ZIP containers.
- Detection of UTF-8 in ZIP string fields now favors Code Page 437 more.
- Renamed build flags included in Cocoapods configurations.
- Fixed multithreading problems for `ZipEntry.data()`.
- Fixed `posixPermissions` in `TarEntry.entryAttributes` containing UNIX type byte in some cases.

## v3.2.0

- Split source files.
- Removed SWCompression/Common subpodspec.
- Moved test files into separate repository as a submodule.
    - Fixed problem with Swift Package Manager requirement to disable smudge-filter of git-lfs.
- Support creation time for TarEntries.
- Add support for ZIP standardized CP437 encoding of string fields.
    - Fallback to UTF-8 if this encoding is unavailable on the platform.
    - Fallback to UTF-8 if it is detected that string fields is in UTF-8.
        - Necessary, because Info-ZIP doesn't marks fields it creates with UTF-8 flag.
- Fixed problem with finding zip64 end of Central Directory locator.
- Fixed problem with accessing `ZipEntry`'s data two or more times.
- Fixed problem with accessing data of BZip2 compressed `ZipEntry`.
- Fixed problem with reading zip64 data descriptor.

## v3.1.3

- Added support for GNU LongLinkName and LongName extensions of TAR format.
- Added support for modification timestamp from extended timestamps ZIP extra field.

## v3.1.2

- `wrongUstarVersion` error is no longer incorrectly thrown for GNU tar containers.

## v3.1.1

- Permissions attributes for TarEntry are now base-10.
- Now throws `fieldIsNotNumber` error when encounters non-number required field in TAR header.
- Slightly improved documentation.

## v3.1.0

- Added support for multi-member GZip archives.
- Added support for multi-stream XZ archives.
- Added property which allows access various entry's attributes for both Tar and ZIP.
- Several Container/Zip/TarEntry's properties are now considered deprecated.
- ZipEntry now provides access to modification time, posix permission and entry type using the new `entryAttributes` property.
- Added support for PAX link path.
- Fixed several problems with decompressing files compressed into ZIP container using LZMA.
- Fixed discarding ZIP containers with `wrongVersion` error when they contain LZMA or BZip2 compressed files.
- Encrypted ZIP containers should now be detected properly.
- `ZipError.compressionNotSupported` is now only thrown when trying to get entry's data and not when just opening the archive.
- Text fields from GZip header are now decoded with correct encoding.
- Improved Deflate comrpession rate for some corner cases.
- Improved BZip2 performance for cases of big data sizes.

## v3.0.1

- Significanty reduced memory usage and improved speed of Deflate compression.

## v3.0.0

- All errors have been renamed, so they conform to Swift Naming Conventions (lowerCamelCase).
- Added `Container` and `ContainerEntry` protocols.
- Most methods have their arguments' labels renamed to make usage shorter.
- Most documentation have been edited to improve readability.
- Multiple files with results of performance tests replaced with consolidated one.
- Enabled support for LZMA and BZip2 compression algorithms.
- `ZipEntry` now conforms to `ContainerEntry` protocol.
- This also means that entry's data is now provided through `ZipEntry.data()` instead of `ZipContainer`'s function.
- Improved detection of directories if ZIP container was created on MS-DOS or UNIX-like systems.
- `ZipError.wrongCRC32` now contains entry's data as associated value.
- Fixed a problem where Zip64 sized fields weren't used during processing of Data Descriptor.
- Added some measures to prevent crashes when it is impossible to read ZIP text fields (file name or comment) in UTF-8 encoding
- Added support for TAR containers in various format versions.
- Now `GzipArchive.unarchive` function unarchives only first 'member' of archive.
- Added support for GZip archive's option in `archive` function.
- `GzipHeader.modificationTime` is now Optional.
- `GzipHeader.originalFileName` renamed to `GzipHeader.fileName`.
- Added `GzipHeader.isTextFile` property which corresponds to same named flag in archive's header.
- Now `XZArchive.unarchive` function unarchives only first stream of archive.
- Check for xz archive's footer's 'magic' bytes is now performed at the beginning of processing.
- XZ header's checksum is now checked before parsing reserved flags.
- BZip2 now performs CRC32 check for decompressed data.
- Removed internal `LZMAOutWindow` auxiliary class.

## v2.4.3

- Fixed incorrect calculation of header's checksum for GZip archives.

## v2.4.2

- Fixed a problem, where ZipEntry.fileName was returning fileComment instead.

## v2.4.1

- Lowered deployment targets versions for all (supported) Apple platforms.

## v2.4.0

- Reduced memory usage in some cases.
- Added Zlib archiving function.

## v2.3.0

- Improved Deflate compression performance.
- Added GZip archiving function.
- Fixed a problem when Deflate uncompressed blocks were created with one extra byte.

## v2.2.2

- Fixed problem with zero-length uncompressed blocks.

## v2.2.1

- Now creates uncompressed block instead of huffman if it will provide better results (in terms of "compression").
- Small internal changes.

## v2.2.0

- Somewhat limited support for Deflate compression.
- API for parsing ZIP entries.

## v2.1.0

- ZIP containers support.
- HuffmanTree is no longer part of SWCompression/Common.
- Updated documentation.

## v2.0.1

- Fixed incorrect reading adler32 checksum from zlib archives.
- Removed LZMA_INFO and LZMA_DIAG build options.
- (2.0.0) GZip archives with multiple 'members' are now parsed correctly.

## v2.0.0

- LZMA decompression.
- XZ unarchiving.
- Once again performance improvement (this time for real).
- Added public API functions for reading gzip/zlib headers.
- Added documentation.
- Added checksums support.
- Added new errors subtypes.
- Added two build options for diagnostical use.
- Rephrased comments to public API.

## v1.2.2

- Small performance improvement.

## v1.2.1

- Removed HuffmanLength.
- Rewritten DataWithPointer.
- Added performance tests.

## v1.2.0

- Reimplemented Huffman Coding using a tree-like structure.
- Now only DataWithPointer is used during the processing.

## v1.1.2

- Fixed memory problem in Deflate.
- Improved overall performance.

## v1.1.1

- Fixed problems when building with Swift Package Manager.
- Added missing files to watchOS scheme.
- Every release on github now will have an archive with pre-built framework.
- Added info about performance to README.

## v1.1.0

- Added BZip2 decompression.
- Introduced subspecs with parts of functionality.
- Additional performance improvements.
- Fixed potential memory problems.
- Added a lot of (educational) comments for Deflate

## v1.0.3

Great performance improvements (but there is still room for more improvements).

## v1.0.2

- Fixed a problem when decompressed amount of data was greater than expected.
- Performance improvement.

## v1.0.1

Fixed several crashes caused by mistyping and shift 'overflow' (when it becomes greater than 15).

## v1.0.0

Initial release, which features support for Deflate, Gzip and Zlib decompression.
