//
//  M3U8VideoCache.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/19.
//

import Foundation

/// 一个 m3u8 视频的缓存框架
class M3U8VideoCache {
    
    /// 开启代理服务器
    /// - Parameter port: 代理服务器的端口号
    static func proxyStart(_ port: Int = 8099) {
        VideoCacheServer.shared.start(port)
    }
    
    /// 停止代理服务器
    static func proxyStop() {
        VideoCacheServer.shared.stop()
    }
    
    /// 创建一个视频代理链接
    /// - Parameter orignalUrl: 原始视频链接
    /// - Returns: 返回链接代理服务器的视频链接
    static func getProxyUrl(_ orignalUrl: URL) -> URL? {
        if let proxyUrl = VideoCacheServer.shared.createProxyUrl(orignalUrl.absoluteString) {
            return URL(string: proxyUrl)
        }
        
        return nil
    }
}
