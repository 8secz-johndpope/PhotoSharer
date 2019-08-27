//
//  TextViewCell.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/27/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit

class TextViewCell: UITableViewCell {

    let textView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    func constructor() {
        contentView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(150)
        }
    }
}
