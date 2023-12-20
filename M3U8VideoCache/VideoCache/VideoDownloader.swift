//
//  VideoDownloader.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/20.
//

import Foundation

/// 视频下载
class VideoDownloader {
    /// 单例
    static let shared = VideoDownloader()
    var task: URLSessionDataTask?
    var session: URLSession?
    
    private init() {
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue())
    }
    
    func download(_ request: URLRequest, completionBlock: ((Data?, URLResponse?, Error?) -> Void)?) {
        if task?.currentRequest != nil {
            // 结束未完成的请求
            task?.cancel();
        }
        
        task = session?.dataTask(with: request, completionHandler: completionBlock!)
        task?.resume();
    }
    
}
