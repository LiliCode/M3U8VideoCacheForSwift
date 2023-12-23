# 视频缓存框架

一个 Swift 版本的 m3u8 视频缓存框架，实现了边播放边缓存，按需缓存。

## 如何使用

1. 在 AppDelegate 中启动代理服务器

    ```swift
    M3U8VideoCache.proxyStart()
    ```

    如果不使用缓存，也可以停止代理服务器

    ```swift
    M3U8VideoCache.proxyStop()
    ```

2. 生成代理请求的视频链接

    ```swift
    let url = M3U8VideoCache.getProxyUrl(URL(string: link)!)
    ```

    完整代码如下所示：

    ```swift
    let link = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    if let url = M3U8VideoCache.getProxyUrl(URL(string: link)!) {
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        present(playerVC, animated: true)
    }
    ```

3. 如上面的代码中，将生成的代理链接放入 `AVPlyaer` 中进行播放

4. 获取缓存大小

    ```swift
    VideoCacheManager.shared.getCacheSize { size, sizeString in
        // size UInt64 类型，文件大小
        // sizeString 格式化之后的文件大小字符串
    }
    ```

5. 清除所有的缓存

    ```swift
    VideoCacheManager.shared.clearAll()
    ```

## 原理

1. 使用 `GCDWebServer` 在本地开启一个代理服务器
2. 用原始视频链接生成一个请求代理服务器的链接，然后交给播放器进行播放
3. 代理服务器拦截到播放器的请求就进行重定向，然后缓存重定向之后结果，下次使用相同的链接就会从缓存中读取结果

## 第三方框架

1. GCDWebServer

## 许可协议

    MIT License

    Copyright (c) 2023 Stan

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
