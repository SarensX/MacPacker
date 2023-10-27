// Copyright (c) 2023 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import BitByteData

/// This type represents the low-level header structure of the TAR format.
struct TarHeader {

    enum HeaderEntryType {
        case normal(ContainerEntryType)
        case special(SpecialEntryType)
    }

    enum SpecialEntryType: UInt8 {
        case longName = 76
        case longLinkName = 75
        case globalExtendedHeader = 103
        case localExtendedHeader = 120
        // Sun were the first to use extended headers. Their headers are mostly compatible with PAX ones, but differ in
        // the typeflag used ("X" instead of "x").
        case sunExtendedHeader = 88
    }

    // These fields are present in all formats.
    let name: String
    let permissions: Permissions?
    let uid: Int?
    let gid: Int?
    let size: Int
    private(set) var mtime: Date?
    // - checksum
    let type: HeaderEntryType
    let linkName: String

    // Ustar only
    // - magic "ustar\000"
    private(set) var uname: String?
    private(set) var gname: String?
    private(set) var deviceMajorNumber: Int?
    private(set) var deviceMinorNumber: Int?
    private(set) var prefix: String?

    // These fields are present in gnu and star formats.
    // - magic ("ustar  \0" for [old] gnu)
    private(set) var atime: Date?
    private(set) var ctime: Date?

    let format: TarContainer.Format
    let blockStartIndex: Int

    init(_ reader: LittleEndianByteReader) throws {
        self.blockStartIndex = reader.offset
        self.name = reader.tarCString(maxLength: 100)

        if let posixAttributes = reader.tarInt(maxLength: 8) {
            // Sometimes file mode field also contains unix type, so we need to filter it out.
            self.permissions = Permissions(rawValue: UInt32(truncatingIfNeeded: posixAttributes) & 0xFFF)
        } else {
            self.permissions = nil
        }

        self.uid = reader.tarInt(maxLength: 8)
        self.gid = reader.tarInt(maxLength: 8)

        guard let size = reader.tarInt(maxLength: 12)
            else { throw TarError.wrongField }
        self.size = size

        if let mtime = reader.tarInt(maxLength: 12) {
            self.mtime = Date(timeIntervalSince1970: TimeInterval(mtime))
        }

        // Checksum
        guard let checksum = reader.tarInt(maxLength: 8)
            else { throw TarError.wrongHeaderChecksum }

        let currentIndex = reader.offset
        reader.offset = blockStartIndex
        var headerBytesForChecksum = reader.bytes(count: 512)
        headerBytesForChecksum.replaceSubrange(148..<156, with: Array(repeating: 0x20, count: 8))
        reader.offset = currentIndex

        // Some implementations treat bytes as signed integers, but some don't.
        // So we check both cases, equality in one of them will pass the checksum test.
        let unsignedOurChecksum = headerBytesForChecksum.reduce(0 as UInt) { $0 + UInt(truncatingIfNeeded: $1) }
        let signedOurChecksum = headerBytesForChecksum.reduce(0 as Int) { $0 + $1.toInt() }
        guard unsignedOurChecksum == UInt(truncatingIfNeeded: checksum) || signedOurChecksum == checksum
            else { throw TarError.wrongHeaderChecksum }

        let fileTypeIndicator = reader.byte()
        if let specialEntryType = SpecialEntryType(rawValue: fileTypeIndicator) {
            self.type = .special(specialEntryType)
        } else {
            self.type = .normal(ContainerEntryType(fileTypeIndicator))
        }

        self.linkName = reader.tarCString(maxLength: 100)

        // There are two different formats utilizing this section of TAR header: GNU format and POSIX (aka "ustar";
        // PAX containers can also be considered as POSIX). They differ in the value of magic field as well as what
        // comes after deviceMinorNumber field. While "ustar" format may contain prefix for file name, GNU format
        // uses this place for storing atime/ctime and fields related to sparse-files. In practice, these fields are
        // rarely used by GNU tar and only present if "incremental backups" options were used. Thus, GNU format TAR
        // container can often be incorrectly considered as having prefix field containing only NULLs.
        let magic = reader.uint64()

        if magic == 0x0020207261747375 || magic == 0x3030007261747375 || magic == 0x3030207261747375 {
            self.uname = reader.tarCString(maxLength: 32)
            self.gname = reader.tarCString(maxLength: 32)
            self.deviceMajorNumber = reader.tarInt(maxLength: 8)
            self.deviceMinorNumber = reader.tarInt(maxLength: 8)

            if magic == 0x00_20_20_72_61_74_73_75 { // GNU format.
                // GNU format is mostly identical to POSIX format and in the common situations can be considered as
                // having prefix containing only NULLs. However, in the case of incremental backups produced by GNU tar
                // this part of the TAR header is used for storing a lot of different properties. For now, we are only
                // reading atime and ctime.
                if let atime = reader.tarInt(maxLength: 12) {
                    self.atime = Date(timeIntervalSince1970: TimeInterval(atime))
                }
                if let ctime = reader.tarInt(maxLength: 12) {
                    self.ctime = Date(timeIntervalSince1970: TimeInterval(ctime))
                }
                self.format = .gnu
            } else {
                self.prefix = reader.tarCString(maxLength: 155)
                self.format = .ustar
            }
        } else {
            self.format = .prePosix
        }
    }

    init(specialName: String, specialType: SpecialEntryType, size: Int, uid: Int?, gid: Int?) {
        self.name = specialName
        self.type = .special(specialType)
        self.size = size
        self.permissions = Permissions(rawValue: 420)
        self.uid = uid
        self.gid = gid
        self.mtime = Date()
        self.linkName = ""
        if specialType == .longName || specialType == .longLinkName {
            self.format = .gnu
        } else if specialType == .globalExtendedHeader || specialType == .localExtendedHeader {
            self.format = .pax
        } else {
            self.format = .prePosix
        }
        // Unused if header was created using this initializer.
        self.blockStartIndex = -1
    }

    init(_ info: TarEntryInfo) {
        self.name = info.name
        self.type = .normal(info.type)
        self.size = info.size ?? 0
        self.atime = info.accessTime
        self.ctime = info.creationTime
        self.mtime = info.modificationTime
        self.permissions = info.permissions
        self.uid = info.ownerID
        self.gid = info.groupID
        self.uname = info.ownerUserName
        self.gname = info.ownerGroupName
        self.deviceMajorNumber = info.deviceMajorNumber
        self.deviceMinorNumber = info.deviceMinorNumber
        self.linkName = info.linkName
        self.format = .pax
        // Unused if header was created using this initializer.
        self.blockStartIndex = -1
    }

    /// This function overrides the value stored in the `format` property.
    func generateContainerData(_ format: TarContainer.Format) -> Data {
        // It is not possible to encode non-english characters with ASCII (expectedly), so we are using UTF-8.
        // While this contradicts format specification, in case of ustar and basic TAR format our other options in
        // situation when it is not possible to encode with ASCII are:
        // - crash with fatalError, etc.
        // - throw an error.
        // - ignore the problem, and just write NULLs.
        // The last option is, obviously, not ideal. Overall, it seems like using UTF-8 instead of ASCII is the most
        // viable option.

        var out = Data()

        out.append(tarString: self.name, maxLength: 100)

        out.append(tarInt: self.permissions?.rawValue.toInt(), maxLength: 8)
        out.append(tarInt: self.uid, maxLength: 8)
        out.append(tarInt: self.gid, maxLength: 8)
        out.append(tarInt: self.size, maxLength: 12)

        if let mtime = self.mtime?.timeIntervalSince1970 {
            out.append(tarInt: Int(mtime), maxLength: 12)
        } else {
            out.append(tarInt: nil, maxLength: 12)
        }

        // Checksum is calculated based on the complete header with spaces instead of checksum.
        out.append(contentsOf: Array(repeating: 0x20, count: 8))

        let fileTypeIndicator: UInt8
        switch self.type {
        case .normal(let entryType):
            fileTypeIndicator = entryType.fileTypeIndicator
        case .special(let specialType):
            fileTypeIndicator = specialType.rawValue
        }
        out.append(fileTypeIndicator)

        out.append(tarString: self.linkName, maxLength: 100)

        // For prePosix format there is no additional fields.

        // Magic
        if format == .ustar || format == .pax {
            out.append(contentsOf: [0x75, 0x73, 0x74, 0x61, 0x72, 0x00, 0x30, 0x30]) // "ustar\000"
        } else if format == .gnu {
            out.append(contentsOf: [0x75, 0x73, 0x74, 0x61, 0x72, 0x20, 0x20, 0x00]) // "ustar  \0"
        }

        if format != .prePosix {
            // Check in case other formats are added in the future.
            assert(format == .ustar || format == .gnu || format == .pax)
            // Both ustar, pax, and gnu formats contain the following four fields.
            // In theory, user/group name is not guaranteed to have only ASCII characters, so the same disclaimer as for
            // file name field applies here.
            out.append(tarString: self.uname, maxLength: 32)
            out.append(tarString: self.gname, maxLength: 32)
            out.append(tarInt: self.deviceMajorNumber, maxLength: 8)
            out.append(tarInt: self.deviceMinorNumber, maxLength: 8)

            // ustar and pax formats contain prefix field.
            if format == .ustar || format == .pax {
                // Splitting the name property into the name and prefix fields.
                let nameData = Data(self.name.utf8)
                if nameData.count > 100 {
                    var maxPrefixLength = nameData.count
                    if maxPrefixLength > 156 {
                        // We can set actual maximum possible length of prefix equal to 156 and not 155, because it may
                        // include trailing slash which will be removed during splitting.
                        maxPrefixLength = 156
                    } else if nameData[maxPrefixLength - 1] == 0x2F {
                        // Skip trailing slash.
                        maxPrefixLength -= 1
                    }

                    // Looking for the last slash in the potential prefix. -1 if not found.
                    // It determines the end of the actual prefix and the beginning of the updated name field.
                    // This way of finding the last slash works, since there is no other Unicode character that contains
                    // the 0x2F byte when encoded in UTF-8.
                    let lastPrefixSlashIndex = nameData.prefix(upTo: maxPrefixLength)
                        .range(of: Data([0x2f]), options: .backwards)?.lowerBound ?? -1
                    let updatedNameLength = nameData.count - lastPrefixSlashIndex - 1
                    let prefixLength = lastPrefixSlashIndex

                    if lastPrefixSlashIndex <= 0 || updatedNameLength > 100 || updatedNameLength == 0 || prefixLength > 155 {
                        // Unsplittable name.
                        out.append(Data(count: 155))
                    } else {
                        // Add prefix data to output.
                        out.append(nameData.prefix(upTo: lastPrefixSlashIndex))
                        // Update name field data in output.
                        var newNameData = nameData.suffix(from: lastPrefixSlashIndex + 1)
                        newNameData.append(Data(count: 100 - newNameData.count))
                        out.replaceSubrange(0..<100, with: newNameData)
                    }
                }
            } else if format == .gnu {
                // Gnu format contains atime and ctime instead of a prefix field.
                if let atime = self.atime?.timeIntervalSince1970 {
                    out.append(tarInt: Int(atime), maxLength: 12)
                } else {
                    out.append(tarInt: nil, maxLength: 12)
                }
                if let ctime = self.ctime?.timeIntervalSince1970 {
                    out.append(tarInt: Int(ctime), maxLength: 12)
                } else {
                    out.append(tarInt: nil, maxLength: 12)
                }
            }
        }

        // Checksum calculation.
        // First, we pad header data to 512 bytes.
        out.append(Data(count: 512 - out.count))
        let checksum = out.reduce(0 as Int) { $0 + $1.toInt() }
        let checksumString = String(format: "%06o", checksum).appending("\0 ")
        out.replaceSubrange(148..<156, with: checksumString.data(using: .ascii)!)

        assert(out.count == 512)

        return out
    }

}
