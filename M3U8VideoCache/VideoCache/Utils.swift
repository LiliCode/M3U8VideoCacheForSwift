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
        _ = data.withUnsafeBytes { bytes in
            return CC_MD5(bytes, CC_LONG(data.count), &digest)
        }

        #endif

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

protocol FileSizeString {
    func toString() -> String
}

extension UInt64: FileSizeString {
    
    /// 转换成文件大小，带单位的字符串
    /// - Returns: 带单位的字符串
    func toString() -> String {
        let suffixs = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(self)
        var idx = 0
        while size > 1000.0 {
            size /= 1000.0
            idx += 1
        }
        
        return "\(size.decimalString(2))\(suffixs[idx])"
    }
    
}

extension Double {
    
    /// 准确的小数尾截取 - 没有进位
    func decimalString(_ base: Self = 1) -> String {
        let tempCount: Self = pow(10, base)
        let temp = self*tempCount
        
        let target = Self(Int(temp))
        let stepone = target / tempCount
        if stepone.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", stepone)
        } else {
            return "\(stepone)"
        }
    }
}
