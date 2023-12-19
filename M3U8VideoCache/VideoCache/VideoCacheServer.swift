//
//  VideoCacheServer.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/19.
//

import Foundation

/// 视频换成代理服务
class VideoCacheServer {
    static let shared = VideoCacheServer()
    var port: Int?
    let host: String = "localhost"
    
    private init() {}
    
    
    /// 开启代理服务器(必须开启才能换成视频)
    /// - Parameter port: 代理服务器的端口号，默认 8099
    /// - Returns: Void
    func start(_ port: Int = 8099) -> Void {
        self.port = port
        
    }
    
    /// 停止代理服务器
    func stop() {
        
    }
    
    /// 创建代理链接
    /// - Parameter orignalUrl: 原视频链接
    /// - Returns: 返回创建好的视频代理链接
    func createProxyUrl(_ orignalUrl: String) -> String? {
        guard orignalUrl.count > 0 else {
            return nil
        }
        
        return "http://\(host):\(port ?? 80)/request?url=\(orignalUrl)"
    }
}
