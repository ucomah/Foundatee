import Foundation

public extension FileManager {

    func fileSizeAtPath(path: String) throws -> Int64 {
        let fileAttributes = try attributesOfItem(atPath: path)
        let fileSizeNumber = fileAttributes[FileAttributeKey.size] as? NSNumber
        let fileSize = fileSizeNumber?.int64Value
        return fileSize ?? 0
    }

    func folderSizeAtPath(path: String) throws -> Int64 {
        var size: Int64 = 0
        let files = try subpathsOfDirectory(atPath: path)
        for i in 0 ..< files.count {
            size += try fileSizeAtPath(path: path.appending("/"+files[i]))
        }
        return size
    }
}

public extension Int64 {

    var stringValue: String {
        let folderSizeStr = ByteCountFormatter.string(fromByteCount: self, countStyle: ByteCountFormatter.CountStyle.file)
        return folderSizeStr
    }
}
