//
//  CameraImageViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/27/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class CameraImageViewController: UIViewController, Sharer {
    func share() {
        let sharer = ShareViewController(shareImage: imageForPresent)
        navigationController?.pushViewController(sharer, animated: true)
    }
    var imageForPresent: UIImage
    var imageView = UIImageView()
    init(presentImage: UIImage) {
        imageForPresent = presentImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageForPresent
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let shareButton = UIButton(type: .system)
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        shareButton.setTitle("Share", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        let cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(cancelButtonTap), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
    }
    

    @objc func shareButtonTap() {
        share()
    }
    @objc func cancelButtonTap() {
        navigationController?.popViewController(animated: true)
    }
        
        
    



}
