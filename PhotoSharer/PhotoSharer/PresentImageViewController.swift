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
    let imageButton = UIButton()
    let imageView = UIImageView()
    var autoDismiss = false
    
    init(presentImage: UIImage?, autoDismiss: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        imageForPresent = presentImage
        self.autoDismiss = autoDismiss
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        imageButton.contentMode = .scaleAspectFit
        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.setImage(imageForPresent, for: .normal)
        view.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if autoDismiss {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            imageButton.addTarget(self, action: #selector(imageButtonTap), for: .touchUpInside)
        }
    }
    
    @objc func imageButtonTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
