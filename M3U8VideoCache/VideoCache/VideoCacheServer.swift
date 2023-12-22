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
        
        guard webServer?.isRunning ?? false else {
            return orignalUrl
        }
        
        guard let serverURLString = serverUrl else {
            return orignalUrl
        }
        
        return "\(serverURLString)\(path)?url=\(orignalUrl)"
    }
    
    func initWebServer() {
        if (webServer == nil) {
            webServer = GCDWebServer()
            webServer!.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) { [weak self] (request, completionBlock) in
                guard let originalUrl = request.url.absoluteString.components(separatedBy: "?url=").last else {
                    completionBlock(GCDWebServerResponse())
                    return
                }
                
                let url = URL(string: originalUrl)!
                var req = URLRequest(url: url, timeoutInterval: 30)
                var headers = request.headers
                headers["Host"] = url.host
                req.allHTTPHeaderFields = headers
                req.httpMethod = "GET"
                
                print("请求的链接: \(originalUrl)")
//                print("请求的 headers: \(req.allHTTPHeaderFields ?? [:])")
                
                self?.requestData(req) { response in
                    DispatchQueue.main.async {
                        completionBlock(response)
                    }
                }
            }
            
            // 开启服务器
            webServer!.start(withPort: port ?? 8099, bonjourName: "GCDWebServer")
            serverUrl = webServer!.serverURL?.absoluteString
        }
    }
    
    /// 请求数据
    func requestData(_ request: URLRequest, completionBlock: ((GCDWebServerResponse) -> Void)?) {
        if (VideoCacheManager.shared.dataExists(request.url!)) {
            // 读取缓存
            VideoCacheManager.shared.readData(request.url!) { [weak self] (data, contentType )in
                if let d = data, let type = contentType  {
                    if request.url!.absoluteString.isM3u8Url() {
                        // 如果是 m3u8 的索引文件，就需要加工一下
                        if let proxyUrl = self?.createProxyUrl(request.url!.absoluteString), let newData = IndexModify.modify(d, url: URL(string: proxyUrl)!) {
                            let serverResponse = GCDWebServerDataResponse(data: newData, contentType: type)
                            serverResponse.statusCode = 200
                            completionBlock?(serverResponse)
                        }
                    } else {
                        let serverResponse = GCDWebServerDataResponse(data: d, contentType: type)
                        serverResponse.statusCode = 200
                        completionBlock?(serverResponse)
                    }
                } else {
                    let serverResponse = GCDWebServerDataResponse()
                    serverResponse.statusCode = 404
                    completionBlock?(serverResponse)
                }
            }
            
            return
        }
        
        // 没有缓存文件，就重新下载
        VideoDownloader.shared.download(request) { [weak self] (data, response, error) in
            var serverResponse = GCDWebServerDataResponse()
            guard let res = response as? HTTPURLResponse else {
                serverResponse.statusCode = 404
                completionBlock?(serverResponse)
                return;
            }
            
            // 存在响应
            if error != nil {
                serverResponse.contentType = res.mimeType ?? ""
                serverResponse.statusCode = res.statusCode
            } else {
                if let d = data {
                    if res.url!.absoluteString.isM3u8Url() {
                        // 如果是 m3u8 的索引文件，就需要加工一下
                        if let proxyUrl = self?.createProxyUrl(res.url!.absoluteString), let newData = IndexModify.modify(d, url: URL(string: proxyUrl)!) {
                            serverResponse = GCDWebServerDataResponse(data: newData, contentType: res.mimeType ?? "")
                            serverResponse.statusCode = res.statusCode
                        }
                    } else {
                        // ts、key 文件直接返回
                        serverResponse = GCDWebServerDataResponse(data: d, contentType: res.mimeType ?? "")
                        serverResponse.statusCode = res.statusCode
                    }
                    
                    // 获取文件响应的一些信息
                    let contentRange = res.allHeaderFields["Content-Range"] as? String
                    let contentLength = res.allHeaderFields["Content-Length"] as? String
                    // 不是数据预取就保存数据
                    if (!((Int(contentLength ?? "0") ?? 0) <= 2 && (contentRange?.contains("bytes 0-1") ?? false))) {
                        // 保存
                        VideoCacheManager.shared.writeData(d, url: res.url!)
                    }
                }
            }
            
            completionBlock?(serverResponse)
        }
    }
}
