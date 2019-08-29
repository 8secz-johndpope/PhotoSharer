//
//  TabBarViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit

class TabBarViewController: UITabBarController {

    let imagePickerVC = ImagePickerViewController()
    let cameraVC = CameraViewController()
    
    let countLabel = UILabel()
    let shareButton = UIButton(type: .system)
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "photoLibrary"), tag: 1)
        
        cameraVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "photoCamera"), tag: 2)
        let tabBarList = [imagePickerVC, cameraVC]
        viewControllers = tabBarList
        
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        shareButton.setTitle("Share", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        let titleLabel = UILabel()
        titleLabel.text = "Photo Sharer"
        navigationItem.titleView = titleLabel
        countLabel.text = ""
        countLabel.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(60)
        }
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.2
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: countLabel)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            imagePickerVC.reloadAssets()
            shareButton.isHidden = false
            countLabel.isHidden = false
        }
        else if(item.tag == 2) {
            shareButton.isHidden = true
            countLabel.isHidden = true
        }
    }
    
    //MARK: - Actions
    
    @objc func shareButtonTap() {
        print("Share")
        if let sharer = selectedViewController as? Sharer {
            sharer.share()
        }
    }
    
    
}
