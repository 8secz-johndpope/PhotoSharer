//
//  PresentImageViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit

class PresentImageViewController: UIViewController {
    
    var imageForPresent: UIImage?
    let imageView = UIImageView()
    
    override func loadView() {
        super.loadView()
        imageView.image = imageForPresent
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
