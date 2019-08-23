//
//  TabBarViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let firstViewController = ImagePickerViewController()
        firstViewController.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "photoLibrary"), tag: 0)
        let secondViewController = CameraViewController()
        secondViewController.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "photoCamera"), tag: 0)
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
    }
    
}
