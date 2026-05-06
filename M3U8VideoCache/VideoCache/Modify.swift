//
//  Modify.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/21.
//

import Foundation

/// 索引文件修改
class IndexModify {
    /// uri 标识
    private static let UriIdentifier = "URI="
    /// key
    private static let KeyIdentifier = "#EXT-X-KEY:"
    /// frame stream
    private static let XIFrameStreamInfoIdentifier = "#EXT-X-I-FRAME-STREAM-INF:"
    /// x media
    private static let XMediaInfoIdentifier = "#EXT-X-MEDIA:"
    /// x map
    private static let XMapIdentifier = "#EXT-X-MAP:"
    
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
            if e.isEmpty { return e }
            if !e.starts(with: "#") {
                // 资源 .ts .m3u8 .mp4 的相对路径
                return createProxyUrl(proxyUrl, removeLastUrl: removeLastUrl.absoluteString, relativePath: e)
            } else if e.starts(with: KeyIdentifier) && e.contains(UriIdentifier) {
                // 单独处理 key
                return processingURI(e, idendifier: KeyIdentifier, proxyUrl: proxyUrl, removeLastUrl: removeLastUrl.absoluteString)
            } else if e.starts(with: XIFrameStreamInfoIdentifier) && e.contains(UriIdentifier) {
                // 单独处理特殊情况的 m3u8 链接
                return processingURI(e, idendifier: XIFrameStreamInfoIdentifier, proxyUrl: proxyUrl, removeLastUrl: removeLastUrl.absoluteString)
            } else if e.starts(with: XMediaInfoIdentifier) && e.contains(UriIdentifier) {
                // 单独处理特殊情况的 m3u8 链接
                return processingURI(e, idendifier: XMediaInfoIdentifier, proxyUrl: proxyUrl, removeLastUrl: removeLastUrl.absoluteString)
            } else if e.starts(with: XMapIdentifier) && e.contains(UriIdentifier) {
                // 单独处理特殊情况的片段链接
                return processingURI(e, idendifier: XMapIdentifier, proxyUrl: proxyUrl, removeLastUrl: removeLastUrl.absoluteString)
            }
            
            return e
        }
        
        let newText = components.joined(separator: "\n")
        return newText.data(using: .utf8)
    }
    
    /// 处理包含 URI 的行（用正则提取 URI="..."，避免逗号拆分误伤）
    private static func processingURI(_ uriRowText: String, idendifier: String, proxyUrl: String?, removeLastUrl: String) -> String {
        let pattern = "URI=\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: uriRowText, range: NSRange(location: 0, length: (uriRowText as NSString).length)),
              let uriRange = Range(match.range(at: 1), in: uriRowText) else {
            return uriRowText
        }
        
        let uri = String(uriRowText[uriRange])
        let proxyUri = createProxyUrl(proxyUrl, removeLastUrl: removeLastUrl, relativePath: uri)
        return uriRowText.replacingCharacters(in: uriRange, with: proxyUri)
    }
    
    private static func createProxyUrl(_ proxyUrl: String?, removeLastUrl: String, relativePath: String) -> String {
        if relativePath.starts(with: "https://") || relativePath.starts(with: "http://") {
            return proxyUrl != nil ? "\(proxyUrl!)\(relativePath)" : relativePath
        }
        
        // 给 ts、m3u8、key 这几个文件的相对路径拼接上完整的链接
        return proxyUrl != nil ? "\(proxyUrl!)\(removeLastUrl)\(relativePath)" : "\(removeLastUrl)\(relativePath)"
    }
}
