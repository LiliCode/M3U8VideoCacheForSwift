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
    private var serverUrl: String?
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
        
        guard let serverURLString = serverUrl else {
            return orignalUrl
        }
        
        return "\(serverURLString)\(path)?url=\(orignalUrl)"
    }
    
    func initWebServer() {
        if (webServer == nil) {
            webServer = GCDWebServer()
            webServer!.addHandler(forMethod: "GET", path: "/\(path)", request: GCDWebServerRequest.self) { [weak self] (request, completionBlock) in
                guard let originalUrl = request.url.absoluteString.components(separatedBy: "\(self?.path ?? "request")?url=").last else {
                    completionBlock(GCDWebServerResponse())
                    return
                }
                
                print("请求的链接: \(originalUrl)")
                
                let url = URL(string: originalUrl)!
                var req = URLRequest(url: url, timeoutInterval: 30)
                req.allHTTPHeaderFields = request.headers
                req.allHTTPHeaderFields?["Host"] = url.host
                req.httpMethod = "GET"
                
                print("请求的 headers: \(req.allHTTPHeaderFields ?? [:])")
                
                self?.requestData(req) { response in
                    completionBlock(response)
                }
            }
            
            // 开启服务器
            webServer!.start(withPort: port ?? 8099, bonjourName: "GCDWebServer")
            serverUrl = webServer!.serverURL?.absoluteString
        }
    }
    
    /// 请求数据
    func requestData(_ request: URLRequest, completionBlock: ((GCDWebServerResponse) -> Void)?) {
        VideoDownloader.shared.download(request) { data, response, error in
            var res = GCDWebServerDataResponse()
            if error != nil, let r = response as? HTTPURLResponse {
                res.contentType = r.mimeType ?? ""
                res.statusCode = r.statusCode
            } else {
                if let d = data, let r = response as? HTTPURLResponse {
                    res = GCDWebServerDataResponse(data: d, contentType: r.mimeType ?? "")
                    res.statusCode = r.statusCode
                    for keyValue in r.allHeaderFields {
                        res.setValue(keyValue.value as? String, forAdditionalHeader: keyValue.key as! String)
                    }
                }
            }
            
            completionBlock?(res)
        }
    }
}
