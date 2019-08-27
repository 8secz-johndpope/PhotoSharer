//
//  TabBarViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    let firstViewController = ImagePickerViewController()
    let secondViewController = CameraViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstViewController.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "photoLibrary"), tag: 1)
        
        secondViewController.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "photoCamera"), tag: 2)
        let tabBarList = [firstViewController, secondViewController]
        viewControllers = tabBarList
        
        let shareButton = UIButton(type: .system)
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        shareButton.setTitle("Share", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        let titleLabel = UILabel()
        titleLabel.text = "Photo Sharer"
        navigationItem.titleView = titleLabel
    }
    
    @objc func shareButtonTap() {
        print("Share")
        if let sharer = selectedViewController as? Sharer {
            sharer.share()
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            firstViewController.reloadAssets()
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else if(item.tag == 2) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    
}
