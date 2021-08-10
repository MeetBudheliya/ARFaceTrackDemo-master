//
//  GlassesCollectionViewCell.swift
//  ARFaceTrackDemo
//
//  Created by Adsum MAC 1 on 09/08/21.
//  Copyright © 2021 Blue Mango Global. All rights reserved.
//

import UIKit

class GlassesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var glassesImageView: UIImageView!
    
    private let cornerRadius:CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = cornerRadius
    }
    
    func setup(with imageName: String){
        glassesImageView.image = UIImage(named: imageName)
    }
}
