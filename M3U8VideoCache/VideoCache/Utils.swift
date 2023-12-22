//
//  Utils.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/21.
//

import Foundation
import CommonCrypto

extension String {
    /// 是否是 m3u8 索引文件链接
    func isM3u8Url() -> Bool {
        return self.hasSuffix(".m3u8") || self.hasSuffix(".m3u")
    }
    
    
    /// 字符串 MD5
    /// - Returns: MD5 字符串
    func md5() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        #if swift(>=5.0)
        
        _ = data.withUnsafeBytes { (bytes:  UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        #else
        let d = data.withUnsafeBytes { bytes in
            return CC_MD5(bytes, CC_LONG(data.count), &digest)
        }

        #endif

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

extension URL {
    
    /// 获取缓存占用的大小（单位：字节）
    /// - Returns: 返回缓存占用的大小
    func cacheSize() -> UInt64 {
        guard isFileURL else { return 0 }
        
        let path = absoluteString.replacingOccurrences(of: "file://", with: "")
        var size: UInt64 = 0
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if exists && isDirectory.boolValue {
            guard let enumerator = FileManager.default.enumerator(atPath: path) else {
                return 0
            }
            
            for e in enumerator.allObjects {
                let fullPath = appendingPathComponent(e as! String)
                size += fullPath.cacheSize()
            }
        } else if exists {
            // 文件
            let attributes = try? FileManager.default.attributesOfItem(atPath: path)
            if let s = attributes?[FileAttributeKey.size] as? UInt64 {
                size += s
            }
        }
        
        return size
    }
    
}
