//
//  VideoCacheManager.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/22.
//

import Foundation

/// 视频缓存管理
class VideoCacheManager {
    static let shared = VideoCacheManager()
    
    // 缓存根目录
    private var videoCacheRoot: String?
    
    private init() {
        // 设置根目录
        setCacheDirectory(nil, simulatorDirectory: nil)
    }
    
    /// 设置缓存存放的文件夹
    /// - Parameter path: 缓存文件夹路径，不设置就是用默认路径
    /// - Parameter simulatorDirectory: 模拟器缓存文件路径(用于调试)，不设置就是用默认路径
    func setCacheDirectory(_ path: String?, simulatorDirectory: String?) {
        #if targetEnvironment(simulator)
        // 模拟器（用于调试）
        videoCacheRoot = simulatorDirectory ?? "/Users/andy/Downloads/videoCache/"
        try? createDirectoryIfNotExists(videoCacheRoot!)
        #else
        // 真机
        videoCacheRoot = path ?? "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? "")/videoCache/";

        if let path = videoCacheRoot {
            try? createDirectoryIfNotExists(path)
        }
        #endif
    }
    
    /// 如果不存在这个文件夹就创建
    /// - Parameter directoryPath: 文件夹路径
    private func createDirectoryIfNotExists(_ directoryPath: String) throws {
        var isDirectory = ObjCBool(true)
        guard !FileManager.default.fileExists(atPath: directoryPath, isDirectory: &isDirectory) else {
            return
        }
        
        try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
    }
    
    
    /// 插入文件夹
    private func insertDirectory(_ directory: String) -> String? {
        guard let root = videoCacheRoot else { return nil }
        let path = "\(root)\(directory)/"
        try? createDirectoryIfNotExists(path)
        return path
    }
    
    /// 通过 url 创建文件路径
    private func fileNameFor(_ url: URL) -> String? {
        var requestUrl = url
        let fileName = requestUrl.lastPathComponent // 文件名
        requestUrl.deleteLastPathComponent()
        let directory = requestUrl.absoluteString.md5() // 文件夹名称
        guard let root = insertDirectory(directory) else { return nil }
        return "\(root)\(fileName)"
    }
    
    /// 存入文件
    /// - Parameters:
    ///   - data: 文件二进制数据
    ///   - url: 该文件的下载链接
    func writeData(_ data: Data, url: URL) {
        guard let filePath = fileNameFor(url) else { return }
        DispatchQueue.global().async {
            let result = FileManager.default.createFile(atPath: filePath, contents: data)
            if result {
                print("文件保存完成: \(filePath) ")
            } else {
                print("❌文件保存失败: \(filePath) ")
            }
            
            print("文件的网络链接: \(url.absoluteString)")
        }
    }
    
    /// 读取缓存数据
    /// - Parameter url: 数据的链接
    /// - Returns: 返回缓存数据
    func readData(_ url: URL, completionBlock: ((Data?, String?) -> Void)?) {
        guard let filePath = fileNameFor(url) else {
            completionBlock?(nil, nil)
            return
        }
        
        DispatchQueue.global().async {
            if FileManager.default.fileExists(atPath: filePath) {
                var contentType = "audio/mpegurl"
                if (url.absoluteString.contains(".ts") || url.absoluteString.contains(".key")) {
                    contentType = "application/octet-stream"
                }
                
                completionBlock?(FileManager.default.contents(atPath: filePath), contentType)
                print("读取缓存文件成功: \(filePath) ")
            } else {
                completionBlock?(nil, nil)
                print("❌读取缓存文件失败: \(filePath) ")
            }
            
            print("文件的网络链接: \(url.absoluteString)")
        }
    }
    
    /// 缓存文件是否存在
    /// - Parameter url: 文件的网络链接
    /// - Returns: true 存在缓存，反之不存在
    func dataExists(_ url: URL) -> Bool {
        guard let filePath = fileNameFor(url) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: filePath)
    }
    
}
