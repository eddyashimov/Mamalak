//
//  CardCell.swift
//  Memory Game For Mamalak
//
//  Created by Edil Ashimov on 5/13/20.
//  Copyright © 2020 Edil Ashimov. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    
    var data: Card? {
        didSet {
            guard let data = data else { return }
            imageView.image = data.image
        }
    }
    
    fileprivate let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 0.9
        contentView.clipsToBounds = true
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        NSLayoutConstraint.activate([
                                        imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor,constant: 5),
                                        imageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor,constant: -5),
                                        imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor,constant: 5),
                                        imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor,constant: -5)])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
