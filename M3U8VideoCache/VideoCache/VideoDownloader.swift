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
    private var tasks: [String: URLSessionTask] = [:]
    
    private init() {
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue())
    }
    
    func download(_ request: URLRequest, completionBlock: ((Data?, URLResponse?, Error?) -> Void)?) {
        guard let requestUri = request.url?.absoluteString else {
            return
        }
        
        if let t = tasks[requestUri] {
            // 结束未完成的请求
            t.cancel();
        }
        
        task = session?.dataTask(with: request, completionHandler: { [weak self] (data, res, e) in
            self?.tasks.removeValue(forKey: res?.url?.absoluteString ?? "")
            print("还剩下 \(self?.tasks.count ?? 0) 个下载任务")
            completionBlock?(data, res, e)
        })
        task?.resume();
        tasks[requestUri] = task
    }
    
}
