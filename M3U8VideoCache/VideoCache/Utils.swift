//
//  Utils.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/21.
//

import Foundation

extension String {
    /// 是否是 m3u8 索引文件链接
    func isM3u8Url() -> Bool {
        return self.hasSuffix(".m3u8") || self.hasSuffix(".m3u")
    }
}
