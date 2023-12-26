//
//  Modify.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/21.
//

import Foundation

/// 索引文件修改
class IndexModify {
    /// key 的标志
    private static let KeyIdentifier = "#EXT-X-KEY:"
    
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
        let components = text.components(separatedBy: "\n").filter({ e in
            return !e.isEmpty
        }).map { e in
            if e.contains(".ts") || e.contains(".m3u8") || e.contains(".key") {
                if e.starts(with: KeyIdentifier) && e.contains(".key") {
                    // 单独处理 key
                    guard let keyInfoString = e.components(separatedBy: KeyIdentifier).last else {
                        return e
                    }
                    
                    let queryList = keyInfoString.components(separatedBy: ",")
                    var query: [String: String] = [:]
                    for e in queryList {
                        let queryKeyValue = e.components(separatedBy: "=")
                        query[queryKeyValue.first ?? ""] = queryKeyValue.last
                    }
                    
                    // 提取 URL
                    let uri = query["URI"]?.replacingOccurrences(of: "\"", with: "")
                    // 生成代理链接
                    let keyProxyUri = createProxyUrl(proxyUrl, removeLastUrl: removeLastUrl.absoluteString, relativePath: uri ?? "")
                    query["URI"] = "\"\(keyProxyUri)\""
                    let keyUriRow = query.keys.map { "\($0)=\(query[$0] ?? "")"}.joined(separator: ",")
                    
                    return KeyIdentifier + keyUriRow
                }
                
                return createProxyUrl(proxyUrl, removeLastUrl: removeLastUrl.absoluteString, relativePath: e)
            }
            
            return e
        }
        
        let newText = components.joined(separator: "\n")
        return newText.data(using: .utf8)
    }
    
    private static func createProxyUrl(_ proxyUrl: String?, removeLastUrl: String, relativePath: String) -> String {
        if relativePath.starts(with: "https://") || relativePath.starts(with: "http://") {
            return proxyUrl != nil ? "\(proxyUrl!)\(relativePath)" : relativePath
        }
        
        // 给 ts、m3u8、key 这几个文件的相对路径拼接上完整的链接
        return proxyUrl != nil ? "\(proxyUrl!)\(removeLastUrl)\(relativePath)" : "\(removeLastUrl)\(relativePath)"
    }
}
