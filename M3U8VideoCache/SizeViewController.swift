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
        
        VideoCacheManager.shared.getCacheSize { size in
            self.label.text = "\(size / 1024 / 1024) MB"
        }
    }
    
}
