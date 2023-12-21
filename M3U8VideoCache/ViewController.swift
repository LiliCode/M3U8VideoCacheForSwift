//
//  ViewController.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/19.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    var tableView: UITableView?
    let dataSource: [String] = [
        "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        "http://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8",
        "https://test-streams.mux.dev/x36xhzz/url_8/193039199_mp4_h264_aac_fhd_7.m3u8"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 列表
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.rowHeight = 50.0
        tableView?.delegate = self
        tableView?.dataSource = self
        view.addSubview(tableView!)
        
        // register cell
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView?.frame = view.bounds
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 播放
        playVideo(dataSource[indexPath.row])
    }
}

extension ViewController {
    
    func playVideo(_ link: String) {
        if let url = M3U8VideoCache.getProxyUrl(URL(string: link)!) {
            print("代理视频链接: \(url.absoluteString)")
            
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(playerItem: AVPlayerItem(url: url))
            present(playerVC, animated: true)
        }
    }
}
