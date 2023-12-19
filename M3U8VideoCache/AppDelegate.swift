//
//  AppDelegate.swift
//  M3U8VideoCache
//
//  Created by Andy on 2023/12/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 开启代理
        M3U8VideoCache.proxyStart()
        
        return true
    }


}

