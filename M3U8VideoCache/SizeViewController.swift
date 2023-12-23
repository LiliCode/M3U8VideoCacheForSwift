//
//  SizeViewController.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/23.
//

import UIKit

class SizeViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    deinit {
        print("SizeViewController Deinit....")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取缓存大小
        VideoCacheManager.shared.getCacheSize { size, sizeString in
            self.label.text = sizeString
        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        // 清除缓存大小
        VideoCacheManager.shared.clearAll()
        // 重新获取缓存大小
        VideoCacheManager.shared.getCacheSize { size, sizeString in
            self.label.text = sizeString
        }
    }
}
