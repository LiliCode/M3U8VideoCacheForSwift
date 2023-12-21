//
//  Modify.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/21.
//

import Foundation

/// 索引文件修改
class IndexModify {
    
    /// 修改
    static func modify(_ data: Data, url: URL) -> Data? {
        guard let text = String(data: data, encoding: .utf8) else {
            return nil;
        }
        
        var removeLastUrl = url
        var proxyUrl: String?
        let separated = "?url="
        if url.absoluteString.contains(separated) {
            let c = url.absoluteString.components(separatedBy: separated)
            proxyUrl = (c.first ?? "") + separated
            removeLastUrl = URL(string: c.last ?? "")!
        }
        
        removeLastUrl.deleteLastPathComponent() // 删除主链接最后一个部件，用于内容切片的链接拼接
        let components = text.components(separatedBy: "\n").map { e in
            if e.contains(".ts") || e.contains(".m3u8") || e.contains(".key") {
                // 给 ts、m3u8、key 这几个文件的相对路径拼接上完整的链接
                return proxyUrl != nil ? "\(proxyUrl!)\(removeLastUrl)\(e)" : "\(removeLastUrl)\(e)"
            }
            
            return e
        }
        
        let newText = components.joined(separator: "\n")
        return newText.data(using: .utf8)
    }
}
