//
//  AppDelegate.swift
//  voice recorder
//
//  Created by Максим Храбрый on 19.01.2020.
//  Copyright © 2020 Xaker. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController()
        if #available(iOS 11.0, *) {
            nav.navigationBar.prefersLargeTitles = true
            nav.navigationItem.largeTitleDisplayMode = .never
            nav.navigationItem.largeTitleDisplayMode = .automatic
        }
        nav.setViewControllers([ViewController()], animated: false)
        window?.rootViewController = nav
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        return true
    }


}

