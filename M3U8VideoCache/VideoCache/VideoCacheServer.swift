//
//  VideoCacheServer.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/19.
//

import Foundation
import GCDWebServer

/// 视频换成代理服务
class VideoCacheServer {
    static let shared = VideoCacheServer()
    private var port: UInt?
    private let host: String = "localhost"
    private let path: String = "request"
    private var webServer: GCDWebServer?
    
    private init() {}
    
    
    /// 开启代理服务器(必须开启才能换成视频)
    /// - Parameter port: 代理服务器的端口号，默认 8099
    /// - Returns: Void
    func start(_ port: UInt = 8099) -> Void {
        self.port = port
        
        // 初始化代理服务器
        initWebServer()
    }
    
    /// 停止代理服务器
    func stop() {
        webServer?.stop()
        webServer = nil
    }
    
    /// 创建代理链接
    /// - Parameter orignalUrl: 原视频链接
    /// - Returns: 返回创建好的视频代理链接
    func createProxyUrl(_ orignalUrl: String) -> String? {
        guard orignalUrl.count > 0 else {
            return nil
        }
        
        return "http://\(host):\(port ?? 8099)/\(path)?url=\(orignalUrl)"
    }
    
    func initWebServer() {
        if (webServer == nil) {
            webServer = GCDWebServer()
            webServer!.addHandler(forMethod: "GET", path: "/\(path)", request: GCDWebServerRequest.self) { request, completionBlock in
                
                // completionBlock(GCDWebServerDataResponse(data: Data(), contentType: "video/mp4"))
                completionBlock(GCDWebServerDataResponse(text: "Hello World!!!"))
            }
            
            // 开启服务器
            webServer!.start(withPort: UInt(port ?? 8099), bonjourName: "GCDWebServer")
        }
    }
}
