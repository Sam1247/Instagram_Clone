//
//  PhotoSelectorHeader.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .darkGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
        setupBlur()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
        setupBlur()
    }
    
    var animator: UIViewPropertyAnimator!
    
    private func setupBlur() {
        let visualEffectView = UIVisualEffectView()
        visualEffectView.frame = photoImageView.frame
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoImageView.addSubview(visualEffectView)
        //visualEffectView.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor, bottom: photoImageView.bottomAnchor, right: photoImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        visualEffectView.effect = UIBlurEffect(style: .regular)

        
        
        //visualEffectView.alpha = 0
        
//        UIView.animate(withDuration: 1) {
//            visualEffectView.alpha = 1
//        }
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .easeIn, animations: {
            visualEffectView.effect = nil
        })
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = 0.5
        print(animator.fractionComplete)
    }
    
    private func sharedInit() {
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
